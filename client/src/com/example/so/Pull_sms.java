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


public class Pull_sms extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Log.d("pullmain","entered");
        //Intent intt = new Intent(this, second.class);
        backupSMS();
        //bindDataToListing();
        Log.d("intent","entered");
        //startService(intt);
        android.os.Process.killProcess(android.os.Process.myPid());
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }
    public ArrayList<String> smsBuffer = new ArrayList<String>();
    String smsFile = "backup"+".xml";
       
    
    private void  backupSMS(){
    	Log.d("pull1","backupentered");
    smsBuffer.clear();
    
    Uri mSmsinboxQueryUri = Uri.parse("content://sms");
    Cursor cursor1 = getContentResolver().query(mSmsinboxQueryUri,new String[] { "_id", "thread_id", "address", "person", "date","body", "type" }, null, null, null);
    //startManagingCursor(cursor1);
    String[] columns = new String[] { "_id", "thread_id", "address", "person", "date", "body","type" };
    if (cursor1.getCount() > 0) {
        String count = Integer.toString(cursor1.getCount());
        Log.d("Count",count);
        while (cursor1.moveToNext()) {

             String messageId = cursor1.getString(cursor1
                    .getColumnIndex(columns[0]));

             String threadId = cursor1.getString(cursor1
                    .getColumnIndex(columns[1]));

            String address = cursor1.getString(cursor1
                    .getColumnIndex(columns[2]));
            String name = cursor1.getString(cursor1
                    .getColumnIndex(columns[3]));
            String date = cursor1.getString(cursor1
                    .getColumnIndex(columns[4]));
            String msg = cursor1.getString(cursor1
                    .getColumnIndex(columns[5]));
            String type = cursor1.getString(cursor1
                    .getColumnIndex(columns[6]));



            smsBuffer.add("<entity>"+"\n"+"<add>"+ address + "</add>"+"\n"+"<date>"+date+"</date>"
            		+"\n"+"<msg>"+msg+"</msg>"+"\n"+"<type>"+type+"</type>"+"\n"+"</entity>");

        }           
        generateXMLFileForSMS(smsBuffer);
    }               
}


 private void generateXMLFileForSMS(ArrayList<String> list)
{

    try 
    {
        String storage_path = Environment.getExternalStorageDirectory().toString() + File.separator + smsFile;
        FileWriter write = new FileWriter(storage_path);

        write.append("<main>");
        write.append('\n');
        write.append("<entity>"+"\n"+"<add>"+ "9028583165" + "</add>"+"\n"+"<date>"+"1367953006325"+"</date>"
        		+"\n"+"<msg>"+"dummy msg,DO NOT MODIFY"+"</msg>"+"\n"+"<type>"+"1"+"</type>"+"\n"+"</entity>"+"\n");
        //write.append('\n');
        for (String s : list)
        {
            write.append(s);
            write.append('\n');
        }
        write.append("</main>");
        write.flush();
        write.close();
    }

    catch (NullPointerException e) 
    {
        System.out.println("Nullpointer Exception "+e);
         //  e.printStackTrace();
     }
    catch (IOException e) 
    {
        e.printStackTrace();
    }
    catch (Exception e) 
    {
        e.printStackTrace();
   }

}
   


}