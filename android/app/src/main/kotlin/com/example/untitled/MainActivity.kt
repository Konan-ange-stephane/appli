package com.example.untitled

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "telecommande/classic_bt"

	@SuppressLint("MissingPermission")
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getBondedDevices" -> {
					try {
						val adapter = BluetoothAdapter.getDefaultAdapter()
						val bonded = mutableListOf<Map<String, String>>()
						if (adapter != null && adapter.isEnabled) {
							val devices: Set<BluetoothDevice> = adapter.bondedDevices
							for (d in devices) {
								bonded.add(mapOf("name" to (d.name ?: ""), "address" to d.address))
							}
						}
						result.success(bonded)
					} catch (e: Exception) {
						Log.e(CHANNEL, "getBondedDevices error", e)
						result.error("ERROR", e.message, null)
					}
				}
				"connect" -> {
					val address = call.argument<String>("address")
					if (address == null) {
						result.error("NO_ADDRESS", "No address provided", null)
						return@setMethodCallHandler
					}
					// Connect asynchronously
					Thread {
						try {
							val adapter = BluetoothAdapter.getDefaultAdapter()
							val device = adapter.getRemoteDevice(address)
							// SPP UUID
							val spp = java.util.UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
							val socket = device.createRfcommSocketToServiceRecord(spp)
							adapter.cancelDiscovery()
							socket.connect()
							// save socket
							synchronized(this) { bluetoothSocket = socket; classicDevice = device }
							result.success(true)
						} catch (e: Exception) {
							Log.e(CHANNEL, "connect error", e)
							try { synchronized(this) { bluetoothSocket?.close() } } catch (_: Exception) {}
							result.success(false)
						}
					}.start()
				}
				"disconnect" -> {
					Thread {
						try {
							synchronized(this) {
								bluetoothSocket?.close()
								bluetoothSocket = null
								classicDevice = null
							}
							result.success(true)
						} catch (e: Exception) {
							Log.e(CHANNEL, "disconnect error", e)
							result.success(false)
						}
					}.start()
				}
				"send" -> {
					val data = call.argument<ByteArray>("data")
					if (data == null) {
						result.error("NO_DATA", "No data provided", null)
						return@setMethodCallHandler
					}
					Thread {
						try {
							synchronized(this) {
								val out = bluetoothSocket?.outputStream
								out?.write(data)
								out?.flush()
							}
							result.success(true)
						} catch (e: Exception) {
							Log.e(CHANNEL, "send error", e)
							result.success(false)
						}
					}.start()
				}
				else -> result.notImplemented()
			}
		}
	}

	// RFCOMM socket and device
	private var bluetoothSocket: BluetoothSocket? = null
	private var classicDevice: BluetoothDevice? = null
}
