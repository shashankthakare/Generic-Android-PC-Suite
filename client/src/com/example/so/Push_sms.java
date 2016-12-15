package com.example.so;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

import android.app.Activity;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Menu;

public class Push_sms extends Activity{
	
	 @Override
	    public void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        setContentView(R.layout.activity_main);
	        Log.d("pullmain","entered");
	        //Intent intt = new Intent(this, second.class);
	        //backupSMS();
	        bindDataToListing();
	        Log.d("intent","entered");
	        //startService(intt);
	        android.os.Process.killProcess(android.os.Process.myPid());
	    }
	    @Override
	    public boolean onCreateOptionsMenu(Menu menu) {
	        getMenuInflater().inflate(R.menu.activity_main, menu);
	        return true;}
	    
	    private void bindDataToListing() {
	    	try {
	    		//setApplicationContext(this);
	    		//getContentResolver().delete(Uri.parse("content://sms/conversations/-1"), null, null);
	    		Uri inboxUri = Uri.parse("content://sms/");
	    		Cursor c = getContentResolver().query(inboxUri , null, null, null, null);
	    		while (c.moveToNext()) {
	    		    try {
	    		        
	    		        String pid = c.getString(0); 
	    		        String uri = "content://sms/" + pid;//for received sms
	    		        getContentResolver().delete(Uri.parse(uri),null, null);
	    		    } catch (Exception e) {
	    		    }
	    		}
	    		
	    		Uri inboxUri2 = Uri.parse("content://sms/sent");//for sent sms
	    					Cursor c1 = getContentResolver().query(inboxUri2 , null, null, null, null);
	    		while (c1.moveToNext()) {
	    		    try {
	    		        
	    		        String pid = c1.getString(0); 
	    		        String uri = "content://sms/" + pid;
	    		        getContentResolver().delete(Uri.parse(uri),null, null);
	    		    } catch (Exception e) {
	    		    }
	    		}
	    		
	    		SAXParserFactory saxparser = SAXParserFactory.newInstance();
	    		SAXParser parser = saxparser.newSAXParser();
	    		XMLReader xmlReader = parser.getXMLReader();
	    		ParsingXmlSms pc = new ParsingXmlSms();
	    		xmlReader.setContentHandler(pc);
	    		
	    		File sdcard = Environment.getExternalStorageDirectory();//Get the xml file
	        	File file = new File(sdcard,"backup.xml");
	    		FileInputStream is = new FileInputStream(file);
	    		//InputStream is= new FileInputStream(file);
	    		//InputStream is = getAssets().open("backup.xml");
	    		xmlReader.parse(new InputSource(is));
	    		
	    		ContentValues values = new ContentValues();
	    		String add="";
	    		String date="";
	    		String body="";
	    		String type="";
	    		//String mid="";
	    		//int j=1;
	    		for(int i=1;i<pc.msg.size();i++)
	    		{
	    			add=""+pc.add.get(i);
	    			date=""+pc.date.get(i);
	    			body=""+pc.msg.get(i);
	    			type=""+pc.type.get(i);
	    			//mid=""+pc.mid.get(i);
	    			values.put("address", add);
	    			values.put("date",date);
	    			values.put("body", body);
	    			values.put("type",type);
	    			values.put("read","1");
	        	    //values.put("_id", mid);
	    		/* if(pc.type.get(i).equalsIgnoreCase("received"))
	        	    getContentResolver().insert(Uri.parse("content://sms/inbox"), values);
	        	 else*/
	        	    getContentResolver().insert(Uri.parse("content://sms/"), values);
	    		}
	        	
	    	} catch (Exception e) {
	    		e.getMessage();
	    	}
	    }

}