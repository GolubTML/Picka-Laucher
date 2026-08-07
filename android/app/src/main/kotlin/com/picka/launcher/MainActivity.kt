package com.picka.launcher

import android.os.Bundle
import com.android.apksig.ApkSigner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import net.lingala.zip4j.ZipFile
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.FilterOutputStream
import java.io.OutputStream
import java.security.KeyStore
import java.security.PrivateKey
import java.security.cert.X509Certificate
import java.util.zip.CRC32
import java.util.zip.Deflater
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "apk_signer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "signApk" -> {
                    val inputApkPath = call.argument<String>("inputPath")!!
                    val outputApkPath = call.argument<String>("outputPath")!!
                    val keystorePassword = call.argument<String>("keystorePassword")!!
                    val keyAlias = call.argument<String>("keyAlias")!!
                    val keyPassword = call.argument<String>("keyPassword")!!

                    thread {
                        try {
                            signApk(
                                inputApkPath = inputApkPath,
                                outputApkPath = outputApkPath,
                                keystorePassword = keystorePassword,
                                keyAlias = keyAlias,
                                keyPassword = keyPassword
                            )
                            runOnUiThread { result.success(outputApkPath) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("SIGN_ERROR", e.message, e.stackTraceToString()) }
                        }
                    }
                }

                "unpackApk" -> {
                    val inputPath = call.argument<String>("apkPath")!!
                    val outputDir = call.argument<String>("outputDir")!!

                    thread {
                        try {
                            unzip(inputPath, outputDir)
                            runOnUiThread { result.success(true) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("UNPACK_ERROR", e.message, e.stackTraceToString()) }
                        }
                    }
                }

                "repackApk" -> {
                    val inputDir = call.argument<String>("inputDir")!!
                    val outputApk = call.argument<String>("outputApk")!!

                    thread {
                        try {
                            repackAndAlignApk(inputDir, outputApk)
                            runOnUiThread { result.success(outputApk) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("REPACK_ERROR", e.message, e.stackTraceToString()) }
                        }
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private class CountingOutputStream(out: OutputStream) : FilterOutputStream(out) {
        var count: Long = 0
            private set

        override fun write(b: Int) {
            out.write(b)
            count++
        }

        override fun write(b: ByteArray, off: Int, len: Int) {
            out.write(b, off, len)
            count += len.toLong()
        }
    }

    private fun unzip(zipFilePath: String, destDirectory: String) {
        val destDir = File(destDirectory)
        if (!destDir.exists()) destDir.mkdirs()
        ZipFile(zipFilePath).extractAll(destDirectory)
    }

    private fun repackAndAlignApk(sourceDir: String, outputApkPath: String) {
        val srcDir = File(sourceDir)
        val outFile = File(outputApkPath)
        if (outFile.exists()) outFile.delete()

        val fos = FileOutputStream(outFile)
        val countingStream = CountingOutputStream(fos)
        val zipOut = ZipOutputStream(countingStream)

        zipOut.setLevel(Deflater.DEFAULT_COMPRESSION)

        val files = srcDir.walkTopDown()
            .filter { it.isFile }
            .filter { !it.relativeTo(srcDir).path.replace('\\', '/').startsWith("META-INF/") }
            .toList()

        for (file in files) {
            val relativePath = file.relativeTo(srcDir).path.replace('\\', '/')
            val entry = ZipEntry(relativePath)

            val isUncompressed = relativePath == "resources.arsc" || relativePath.startsWith("assets/")
            val alignment = 4L

            if (isUncompressed) {
                entry.method = ZipEntry.STORED
                val size = file.length()
                entry.size = size
                entry.compressedSize = size

                val crc = CRC32()
                file.inputStream().use { input ->
                    val buffer = ByteArray(8192)
                    var bytesRead: Int
                    while (input.read(buffer).also { bytesRead = it } != -1) {
                        crc.update(buffer, 0, bytesRead)
                    }
                }
                entry.crc = crc.value

                val fileNameBytes = relativePath.toByteArray(Charsets.UTF_8)
                val baseHeaderSize = 30 + fileNameBytes.size
                val rawOffset = countingStream.count + baseHeaderSize
                val mod = (rawOffset + 4) % alignment
                val padding = if (mod == 0L) 0L else (alignment - mod)
                val extraSize = (4 + padding).toInt()
                val extraBytes = ByteArray(extraSize)
                extraBytes[0] = 0x05.toByte()
                extraBytes[1] = 0xd9.toByte()
                extraBytes[2] = (padding and 0xFF).toByte()
                extraBytes[3] = ((padding shr 8) and 0xFF).toByte()
                entry.extra = extraBytes

                zipOut.putNextEntry(entry)
                file.inputStream().use { input ->
                    input.copyTo(zipOut)
                }
            } else {
                entry.method = ZipEntry.DEFLATED
                zipOut.putNextEntry(entry)
                file.inputStream().use { input ->
                    input.copyTo(zipOut)
                }
            }
            zipOut.closeEntry()
        }
        zipOut.close()
    }

    private fun copyKeystoreFromAssets(): File {
        val outFile = File(cacheDir, "picka.keystore")
        assets.open("picka.keystore").use { input ->
            outFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
        return outFile
    }

    private fun signApk(
        inputApkPath: String,
        outputApkPath: String,
        keystorePassword: String,
        keyAlias: String,
        keyPassword: String,
    ) {
        val keystoreFile = copyKeystoreFromAssets()

        val keyStore = KeyStore.getInstance("PKCS12")
        keystoreFile.inputStream().use {
            keyStore.load(it, keystorePassword.toCharArray())
        }

        val privateKey = keyStore.getKey(keyAlias, keyPassword.toCharArray()) as PrivateKey
        val certChain = keyStore.getCertificateChain(keyAlias).map { it as X509Certificate }
        val signerConfig = ApkSigner.SignerConfig.Builder("signer", privateKey, certChain).build()

        println("Private key: ${privateKey.algorithm}")
        println("Certificates: ${certChain.size}")
        println("Alias: $keyAlias")
        println("Keystore type: ${keyStore.type}")

        ApkSigner.Builder(listOf(signerConfig))
            .setInputApk(File(inputApkPath))
            .setOutputApk(File(outputApkPath))
            .setV1SigningEnabled(true)
            .setV2SigningEnabled(true)
            .setV3SigningEnabled(true)
            .build()
            .sign()
    }
}