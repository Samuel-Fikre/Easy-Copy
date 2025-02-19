package com.example.hello_world

import android.content.ClipboardManager
import android.content.ClipData
import android.content.Context
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.widget.Toast

class QuickTileService : TileService() {
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
            val accountNumber = sharedPreferences.getString("flutter.bankAccount", "")
            
            if (accountNumber.isNullOrEmpty()) {
                showToast("No account number saved!")
                return
            }

            copyToClipboard(accountNumber)
            showToast("Account Number Copied!")
        } catch (e: Exception) {
            showToast("Failed to read account number")
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