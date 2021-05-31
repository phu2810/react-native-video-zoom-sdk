package com.reactnativevideozoomsdk;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;

import androidx.core.app.NotificationCompat;


public class NotificationMgr {

  public final static int PT_NOTIFICATION_ID = 4;

  public static final String ZOOM_NOTIFICATION_CHANNEL_ID = "English4SchoolsChannel";

  public static Notification getConfNotification(Context context) {

    if (context == null)
      return null;

    String contentTitle = context.getString(R.string.app_name);
    String contentText = context.getString(R.string.notification_text);

    int smallIcon = R.drawable.ic_launcher;

    //Intent clickIntent = new Intent(context, IntegrationActivity.class);
    //clickIntent.setAction(IntegrationActivity.ACTION_RETURN_TO_CONF);
    //PendingIntent contentIntent = PendingIntent.getActivity(context, 0, clickIntent, PendingIntent.FLAG_CANCEL_CURRENT);

    NotificationCompat.Builder builder = NotificationMgr.getNotificationCompatBuilder(context.getApplicationContext(), false);

    builder.setWhen(0)
      .setAutoCancel(false)
      .setOngoing(true)
      .setSmallIcon(smallIcon)
      .setContentTitle(contentTitle)
      .setContentText(contentText)
      .setOnlyAlertOnce(true);
    //.setContentIntent(contentIntent);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_launcher);
      builder.setLargeIcon(largeIcon);
    }
    return builder.build();
  }

  public static void removeConfNotification(Context context) {
    if (context == null)
      return;
    NotificationManager notificationMgr = (NotificationManager) context.getSystemService(Activity.NOTIFICATION_SERVICE);
    notificationMgr.cancel(NotificationMgr.PT_NOTIFICATION_ID);
  }

  public static NotificationCompat.Builder getNotificationCompatBuilder(Context context, boolean isHighImportance) {
    NotificationCompat.Builder builder;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationManager notificationMgr = (NotificationManager) context
        .getSystemService(Activity.NOTIFICATION_SERVICE);
      NotificationChannel notificationChannel = notificationMgr.getNotificationChannel(getNotificationChannelId());
      if (notificationChannel == null) {
        notificationChannel = new NotificationChannel(getNotificationChannelId(), "English4Schools Notification",
          isHighImportance ? NotificationManager.IMPORTANCE_HIGH : NotificationManager.IMPORTANCE_DEFAULT);
        notificationChannel.enableVibration(true);
        if (notificationChannel.canShowBadge())
          notificationChannel.setShowBadge(false);
      }

      notificationMgr.createNotificationChannel(notificationChannel);
      builder = new NotificationCompat.Builder(context, getNotificationChannelId());
    } else {
      builder = new NotificationCompat.Builder(context);
    }
    return builder;
  }

  public static String getNotificationChannelId() {
    return ZOOM_NOTIFICATION_CHANNEL_ID;
  }
}
