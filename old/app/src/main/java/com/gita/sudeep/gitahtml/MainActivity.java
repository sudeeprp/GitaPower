package com.gita.sudeep.gitahtml;

import android.app.Activity;
import android.app.SearchManager;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Pair;
import android.util.Xml;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebBackForwardList;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.JavascriptInterface;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

class WebAppInterface {
    Activity mActivity;

    /** Instantiate the interface and set the context */
    WebAppInterface(Activity a) {
        mActivity = a;
    }

    /** Show a toast from the web page */
    @JavascriptInterface
    public void showToast(String toast) {
        mActivity.onSearchRequested();
    }
}

class H2Marker {
    String[] searchWords;
    boolean[] wordsFound;
    public StringBuilder markedPara = new StringBuilder();

    public H2Marker(String[] wordsToSearch) {
        searchWords = wordsToSearch;
        wordsFound = new boolean[searchWords.length];
    }
    public boolean AllWordsFound() {
        for(boolean wordFound: wordsFound) {
            if(false == wordFound) {
                return false;
            }
        }
        return true;
    }
    public void FeedSentence(String sentence) {
        TreeSet<Pair<Integer,Integer>> markerPairs = new TreeSet <Pair<Integer,Integer>>(new Comparator<Pair<Integer,Integer>>() {
            @Override
            public int compare(Pair<Integer,Integer> a1, Pair<Integer,Integer> a2) {
                return a1.first - a2.first;
            }
        });
        //Find all begin and end markers
        for(int i = 0; i < searchWords.length; i++) {
            String word = searchWords[i];
            int searchCursor = 0, foundPos = 0;
            while (-1 != (foundPos = sentence.indexOf(word, searchCursor))) {
                //Move the cursor forward
                searchCursor = foundPos + word.length();
                //Remember the markers
                Pair<Integer,Integer> markerPair = Pair.create(foundPos, searchCursor);
                markerPairs.add(markerPair);
                wordsFound[i] = true;
            }
        }

        //Form the marked string- scan from the beginning to construct it
        int sourceCursor = 0;
        for(Pair<Integer,Integer> markerPair : markerPairs) {
            markedPara.append(sentence.substring(sourceCursor, markerPair.first));
            markedPara.append("<b>");
            markedPara.append(sentence.substring(markerPair.first, markerPair.second));
            markedPara.append("</b>");
            sourceCursor = markerPair.second;
        }
        //If something was marked, grab the remaining part of the sentence
        if(markerPairs.size() > 0) {
            markedPara.append(sentence.substring(sourceCursor, sentence.length()));
        }
    }
}

public class MainActivity extends AppCompatActivity {
    WebView myBrowser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Make full screen
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.activity_main);

        // Initialize browser and its reference
        myBrowser=(WebView)findViewById(R.id.mybrowser);
        myBrowser.getSettings().setJavaScriptEnabled(true);
        myBrowser.setWebViewClient(new WebViewClient());
        myBrowser.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        myBrowser.setScrollbarFadingEnabled(false);
        myBrowser.addJavascriptInterface(new WebAppInterface(this), "GitaHTML");

        // Get the intent, if it's a search, show results and leave
        Intent intent = getIntent();
        if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
            try {
                ExecSearchIntent(intent);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (XmlPullParserException e) {
                e.printStackTrace();
            }
        }
        else {
            // Recover the state if it's there, otherwise go to initial URL
            restoreInstanceState(savedInstanceState);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        setIntent(intent);
        try {
            if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
                ExecSearchIntent(intent);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (XmlPullParserException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        restoreInstanceState(savedInstanceState);
    }

    private void restoreInstanceState(Bundle savedInstanceState) {
        String urlToRestore = "file:///android_asset/ACover.html";
        if(savedInstanceState != null) {
            String savedUrl = savedInstanceState.getString("SAVED_URL");
            if (savedUrl != null && !savedUrl.isEmpty()) {
                urlToRestore = savedUrl;
            }
        }
        myBrowser.loadUrl(urlToRestore);
    }

    // invoked when the activity may be temporarily destroyed, save the instance state here
    @Override
    public void onSaveInstanceState(Bundle outState) {
        String currentUrl = myBrowser.getUrl();
        outState.putString("SAVED_URL", currentUrl);

        // call superclass to save any view hierarchy
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onBackPressed() {
        if (myBrowser.canGoBack()) {
            WebBackForwardList bhistory = myBrowser.copyBackForwardList();
            int i = bhistory.getCurrentIndex();
            String prevUrl =  bhistory.getItemAtIndex(i-1).getUrl();

            //Go back one step and check if it was the search screen
            myBrowser.goBack();
            if(prevUrl.startsWith("data:")) {
                //The search screen would be blank, so go back one more step and dont show it.
                //Doing ExecSearch here would put it in the wrong place on the history, resulting in infinite back-loops
                myBrowser.goBack();
            }
            else if(prevUrl.contains("#") && !prevUrl.contains("?e") && !prevUrl.contains("?c")) {
                //if the URL contained # and no coordinates, navigate to the hash
                myBrowser.loadUrl("javascript:gotohash();");
            }
        } else {
            //This is to exit
            super.onBackPressed();
        }
    }

    private void ExecSearchIntent(Intent intent) throws IOException, XmlPullParserException {
        String searchString = intent.getStringExtra(SearchManager.QUERY); //insensitive? .toLowerCase();
        ExecSearch(searchString);
    }
    private String[] prepSearchWords(String[] words) {
        Set<String> wordSet = new HashSet<String>(Arrays.asList(words));
        String stopWords = "be on if no at and was not am with do did by the when they it its it's is are or as so to";
        ArrayList<String> wordsToRemove = new ArrayList<String>();
        for(String word: wordSet) {
            if(word.length() < 2 || stopWords.contains(word)) {
                wordsToRemove.add(word);
            }
        }
        for(String word: wordsToRemove) {
            wordSet.remove(word);
        }
        return wordSet.toArray(new String[0]);
    }
    private void ExecSearch(String searchString) throws IOException, XmlPullParserException {
        if(null == searchString || searchString.length() == 0) {
            return;
        }
        String[] wordsToSearch = prepSearchWords(searchString.split(" "));

        StringBuilder queryResult = new StringBuilder(
                "<!DOCTYPE html><html><body>" +
                "<div style=\"background:Beige;font-family:\'Arial\',\'serif\';font-size:11.0pt;line-height:150%;\">\n" +
                String.format("<h1>Searched %s</h1>", searchString));

        InputStream xmlInputStream = getAssets().open("features.xml");
        XmlPullParser parser = Xml.newPullParser();
        parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
        parser.setInput(xmlInputStream, null);
        parser.nextTag();
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name_1 = parser.getName();
            if (name_1.equals("taggedtext")) {
                //Fill one feature entry
                String h1name = "", h2name = "", link = "";
                H2Marker h2Marker = new H2Marker(wordsToSearch);
                while (parser.next() != XmlPullParser.END_TAG) {
                    if (parser.getEventType() != XmlPullParser.START_TAG) {
                        continue;
                    }
                    String tagname = parser.getName();
                    //Go to the content
                    parser.next();
                    if (tagname.equals("h1name")) {
                        h1name = parser.getText();
                    } else if (tagname.equals("h2name")) {
                        h2name = parser.getText();
                    } else if (tagname.equals("link")) {
                        link = parser.getText();
                    } else if (tagname.equals("text")) {
                        h2Marker.FeedSentence(parser.getText());
                    }
                    //pull out the end tag
                    parser.next();
                }
                //Add to query result if all search words were found
                if(h2Marker.AllWordsFound()) {
                    queryResult.append(String.format("<p><a href=\"%s\">", link));
                    queryResult.append(h1name);
                    if(h2name != null) {
                        queryResult.append(String.format(" / %s<br>", h2name));
                    }
                    queryResult.append("</a>");
                    queryResult.append(h2Marker.markedPara);
                    //If the queryResult has grown large enough, quit
                    if(queryResult.length() >= 256 * 1024) {
                        break;
                    }
                }
            }
            //pull out the end tag
            parser.next();
        }
        queryResult.append("</div></body></html>");
        myBrowser.loadDataWithBaseURL("file:///android_asset/", queryResult.toString(),
                   "text/html", null, null);
    }
}
