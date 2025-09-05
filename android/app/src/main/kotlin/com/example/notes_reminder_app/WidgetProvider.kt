package com.example.notes_reminder_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.preference.PreferenceManager

class WidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_provider)
            val prefs = PreferenceManager.getDefaultSharedPreferences(context)
            val note = prefs.getString("latest_note", context.getString(R.string.no_notes))
            views.setTextViewText(R.id.widget_note, note)

            val intent = Intent(context, MainActivity::class.java)
            intent.putExtra("action", "quick_add")
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent, PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quick_add, pendingIntent)

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
