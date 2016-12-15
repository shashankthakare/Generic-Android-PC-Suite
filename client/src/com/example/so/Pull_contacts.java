package com.example.so;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.ContactsContract;
import android.app.Activity;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.util.Log;
import android.view.Menu;

public class Pull_contacts extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getVCF(); 
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }

public void getVCF() 
{
	//Context mContext = null;
    final String vfile = "backup_contacts.vcf";
    Cursor phones = getApplicationContext().getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null,
                    null, null, null);
    phones.moveToFirst();
    for(int i =0;i<phones.getCount();i++)
    {
         String lookupKey = phones.getString(phones.getColumnIndex(ContactsContract.Contacts.LOOKUP_KEY));
         Uri uri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_VCARD_URI, lookupKey);
         AssetFileDescriptor fd;
         try 
         {
             fd = getApplicationContext().getContentResolver().openAssetFileDescriptor(uri, "r");
             FileInputStream fis = fd.createInputStream();
             byte[] buf = new byte[(int) fd.getDeclaredLength()];
             fis.read(buf);
             String VCard = new String(buf);
             String path = Environment.getExternalStorageDirectory().toString() + File.separator + vfile;
             FileOutputStream mFileOutputStream = new FileOutputStream(path, true);
                        mFileOutputStream.write(VCard.toString().getBytes());           
             phones.moveToNext();                           
             Log.d("Vcard",  VCard);
         } 
         catch (Exception e1) 
         {
              // TODO Auto-generated catch block
              e1.printStackTrace();
         }
    }
}

}