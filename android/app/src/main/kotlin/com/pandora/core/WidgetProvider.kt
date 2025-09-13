package com.pandora.core

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.preference.PreferenceManager

class WidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        val prefs = PreferenceManager.getDefaultSharedPreferences(context)
        val latestNote = prefs.getString("latest_note", context.getString(R.string.no_notes))

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_provider)
            views.setTextViewText(R.id.widget_note, latestNote)

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_note, pendingIntent)

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
