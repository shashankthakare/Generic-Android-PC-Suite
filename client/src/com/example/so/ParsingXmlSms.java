package com.example.so;

import java.util.ArrayList;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class ParsingXmlSms extends DefaultHandler {

	ArrayList<String> add = new ArrayList<String>();
	ArrayList<String> date = new ArrayList<String>();
	ArrayList<String> msg = new ArrayList<String>();
	ArrayList<String> type = new ArrayList<String>();
	//ArrayList<String> mid = new ArrayList<String>();
	//ArrayList<String> tid = new ArrayList<String>();
	//ArrayList<String> name = new ArrayList<String>();
	@Override
	public void startElement(String uri, String localName, String qName,
			Attributes attributes) throws SAXException {
		super.startElement(uri, localName, qName, attributes);
		if (localName.equalsIgnoreCase("add")) {
			tempStore = "";
		} 
		else if (localName.equalsIgnoreCase("date")) {
			tempStore = "";
		}
		else if (localName.equalsIgnoreCase("msg")) {
			tempStore = "";
		} else if (localName.equalsIgnoreCase("type")) {
			tempStore = "";
		}
		/*else if (localName.equalsIgnoreCase("mid")) {
			tempStore = "";
		}
		else if (localName.equalsIgnoreCase("tid")) {
			tempStore = "";
		}
		else if (localName.equalsIgnoreCase("name")) {
			tempStore = "";
		}*/
		else{
			tempStore = "";
		}
	}

	@Override
	public void endElement(String uri, String localName, String qName)
			throws SAXException {
		super.endElement(uri, localName, qName);
		if (localName.equalsIgnoreCase("add")) {
			add.add(tempStore);
		} 
		else if (localName.equalsIgnoreCase("date")) {
			date.add(tempStore);
		}
		else if (localName.equalsIgnoreCase("msg")) {
			msg.add(tempStore);
		} else if (localName.equalsIgnoreCase("type")) {
			type.add(tempStore);
		}
		/*else if (localName.equalsIgnoreCase("mid")) {
			type.add(tempStore);
		}
		else if (localName.equalsIgnoreCase("tid")) {
			type.add(tempStore);
		}
		else if (localName.equalsIgnoreCase("name")) {
			type.add(tempStore);
		}*/
		
		tempStore = "";
	}

	private String tempStore = "";

	@Override
	public void characters(char[] ch, int start, int length)
			throws SAXException {
		super.characters(ch, start, length);
		tempStore += new String(ch, start, length);
	}
}

