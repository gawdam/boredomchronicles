package com.example.boredomapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

import es.antonborri.home_widget.HomeWidgetPlugin




class BoredomWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds){
            
            val widgetData = HomeWidgetPlugin.getData(context)

            val views = RemoteViews(context.packageName, R.layout.boredom_widget).apply {

                val title = widgetData.getString("headline_title", null)
                setTextViewText(R.id.headline_title, title ?: "No title set")

                val description = widgetData.getString("headline_description", null)
                setTextViewText(R.id.headline_description, description ?: "BORED")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
            
        }
    }
}
