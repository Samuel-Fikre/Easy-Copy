package com.example.hello_world

import android.content.ClipboardManager
import android.content.ClipData
import android.content.Context
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.widget.Toast
import android.app.AlertDialog
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import android.util.Log

class QuickTileService : TileService() {
    companion object {
        private const val TAG = "QuickTileService"
    }

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_ACTIVE
            label = "Copy Account"
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        try {
            val sharedPreferences = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Debug: List all keys in SharedPreferences
            val allPrefs = sharedPreferences.all
            Log.d(TAG, "All SharedPreferences keys and values:")
            allPrefs.forEach { (key, value) ->
                Log.d(TAG, "Key: $key, Value: $value")
            }
            
            val rawData = sharedPreferences.getString("flutter.flutter.bankAccounts", null)
            Log.d(TAG, "Raw data from SharedPreferences: $rawData")

            if (rawData == null) {
                showToast("No bank accounts saved!")
                return
            }

            // Remove the prefix that Flutter adds to the list
            val cleanData = rawData.substringAfter("!")

            // Clean up the string and split into individual entries
            val entries = cleanData
                .replace("[", "")
                .replace("]", "")
                .split(",")
                .map { it.trim() }
                .filter { it.isNotEmpty() }

            Log.d(TAG, "Split entries: $entries")

            val accounts = mutableListOf<BankAccount>()
            for (entry in entries) {
                try {
                    Log.d(TAG, "Processing entry: $entry")
                    val bankName = entry.substringAfter("bankName=").substringBefore("&")
                    val accountNumber = entry.substringAfter("accountNumber=")
                    
                    Log.d(TAG, "Extracted - bankName: $bankName, accountNumber: $accountNumber")
                    
                    if (bankName.isNotEmpty() && accountNumber.isNotEmpty()) {
                        val decodedBankName = android.net.Uri.decode(bankName)
                        val decodedAccountNumber = android.net.Uri.decode(accountNumber).trim('"')
                        accounts.add(BankAccount(decodedBankName, decodedAccountNumber))
                        Log.d(TAG, "Successfully added account: $decodedBankName - $decodedAccountNumber")
                    } else {
                        Log.w(TAG, "Empty bankName or accountNumber in entry: $entry")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing entry: $entry", e)
                }
            }

            Log.d(TAG, "Final parsed accounts: $accounts")

            if (accounts.isEmpty()) {
                showToast("No valid bank accounts found!")
                return
            }

            // If there's only one account, copy it directly
            if (accounts.size == 1) {
                copyToClipboard(accounts[0].accountNumber)
                showToast("${accounts[0].bankName.replace("+", " ")} account copied!")
                return
            }

            // Show selection dialog for multiple accounts
            showAccountSelection(accounts)
        } catch (e: Exception) {
            Log.e(TAG, "Error reading bank accounts", e)
            showToast("Failed to read bank accounts: ${e.message}")
        }
    }

    private fun showAccountSelection(accounts: List<BankAccount>) {
        Handler(Looper.getMainLooper()).post {
            val dialog = AlertDialog.Builder(this, android.R.style.Theme_DeviceDefault_Dialog_Alert)
                .setTitle("Select Bank Account")
                .setItems(accounts.map { "${it.bankName.replace("+", " ")}" }.toTypedArray()) { _, which ->
                    copyToClipboard(accounts[which].accountNumber)
                    showToast("${accounts[which].bankName.replace("+", " ")} account copied!")
                }
                .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
                .create()

            dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
            
            // Check if we have overlay permission
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                return@post
            }
            
            dialog.show()
        }
    }

    private fun copyToClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Bank Account", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun showToast(message: String) {
        Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
    }
}

data class BankAccount(
    val bankName: String,
    val accountNumber: String
) {
    override fun toString(): String {
        return "BankAccount(bankName='$bankName', accountNumber='$accountNumber')"
    }
} 