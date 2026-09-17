package com.schaglk.studio;

import android.app.*;
import android.os.*;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.Editable;
import android.text.TextWatcher;
import android.webkit.*;
import android.view.*;
import android.view.inputmethod.EditorInfo;
import android.widget.*;
import java.io.*;
import java.util.*;

public class MainActivity extends Activity {

    final int BG=Color.rgb(18,26,36);
    final int PANEL=Color.rgb(27,38,51);
    final int EDITOR=Color.rgb(14,22,32);
    final int BLUE=Color.rgb(38,132,232);
    final int TEXT=Color.rgb(232,239,247);

    LinearLayout root, filesPanel, tabs, terminalPanel;
    EditText editor, commandInput;
    TextView terminalOutput, status;
    WebView live;
    File workspace, currentFile;
    ArrayList<File> openFiles=new ArrayList<>();
    int currentTab=-1;

    final ArrayDeque<String> undoStack=new ArrayDeque<>();
    final ArrayDeque<String> redoStack=new ArrayDeque<>();
    boolean historySuppressed=false;
    static final int MAX_HISTORY=100;

    @Override public void onCreate(Bundle b){
        super.onCreate(b);
        workspace=new File(getFilesDir(),"workspace");
        workspace.mkdirs();
        buildUI();
        ensureStarter();
        refreshFiles();
        openFile(new File(workspace,"index.html"));
    }

    TextView label(String s,int size){
        TextView t=new TextView(this);
        t.setText(s);
        t.setTextColor(TEXT);
        t.setTextSize(size);
        t.setGravity(Gravity.CENTER_VERTICAL);
        t.setPadding(10,5,10,5);
        return t;
    }

    Button btn(String s){
        Button b=new Button(this);
        b.setText(s);
        b.setTextColor(TEXT);
        b.setTextSize(11);
        b.setAllCaps(false);
        return b;
    }

    void buildUI(){
        root=new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BG);

        LinearLayout top=new LinearLayout(this);
        top.setBackgroundColor(PANEL);

        TextView title=label("  SCHAGLK  •  CREATION LAB",18);
        title.setTypeface(Typeface.DEFAULT,Typeface.BOLD);
        top.addView(title,new LinearLayout.LayoutParams(0,60,1));

        Button ai=btn("IA");
        ai.setOnClickListener(v->ai());
        top.addView(ai,new LinearLayout.LayoutParams(70,60));

        root.addView(top);

        LinearLayout body=new LinearLayout(this);
        body.setOrientation(LinearLayout.HORIZONTAL);

        filesPanel=new LinearLayout(this);
        filesPanel.setOrientation(LinearLayout.VERTICAL);
        filesPanel.setPadding(5,5,5,5);
        filesPanel.setBackgroundColor(PANEL);

        LinearLayout fpbar=new LinearLayout(this);
        Button nf=btn("+ FICHIER");
        nf.setOnClickListener(v->createFileDialog());
        Button nd=btn("+ DOSSIER");
        nd.setOnClickListener(v->createFolderDialog());
        fpbar.addView(nf,new LinearLayout.LayoutParams(0,50,1));
        fpbar.addView(nd,new LinearLayout.LayoutParams(0,50,1));
        filesPanel.addView(fpbar);

        ScrollView fscroll=new ScrollView(this);
        LinearLayout fcontent=new LinearLayout(this);
        fcontent.setOrientation(LinearLayout.VERTICAL);
        fscroll.addView(fcontent);
        filesPanel.addView(fscroll,new LinearLayout.LayoutParams(-1,0,1));

        body.addView(filesPanel,new LinearLayout.LayoutParams(0,-1,0.20f));

        LinearLayout center=new LinearLayout(this);
        center.setOrientation(LinearLayout.VERTICAL);

        tabs=new LinearLayout(this);
        tabs.setBackgroundColor(PANEL);
        center.addView(tabs,new LinearLayout.LayoutParams(-1,48));

        LinearLayout bar=new LinearLayout(this);
        String[] actions={"NOUVEAU","OUVRIR","SAUVER","UNDO","REDO","CHERCHER","TEST"};
        for(String s:actions){
            Button x=btn(s);
            x.setOnClickListener(v->{
                switch(s){
                    case "NOUVEAU": createFileDialog(); break;
                    case "OUVRIR": refreshFiles(); break;
                    case "SAUVER": save(); break;
                    case "UNDO": undo(); break;
                    case "REDO": redo(); break;
                    case "CHERCHER": findDialog(); break;
                    case "TEST": preview(); break;
                }
            });
            bar.addView(x,new LinearLayout.LayoutParams(0,48,1));
        }
        center.addView(bar);

        editor=new EditText(this);
        editor.setTextColor(TEXT);
        editor.setHintTextColor(Color.GRAY);
        editor.setTextSize(14);
        editor.setGravity(Gravity.TOP|Gravity.START);
        editor.setBackgroundColor(EDITOR);
        editor.setSingleLine(false);
        editor.setPadding(12,12,12,12);
        editor.setTypeface(Typeface.MONOSPACE);
        editor.setInputType(131073);

        editor.addTextChangedListener(new TextWatcher(){
            @Override public void beforeTextChanged(CharSequence s,int start,int count,int after){
                if(historySuppressed)return;
                if(count==0 && after==0)return;
                if(undoStack.size()>=MAX_HISTORY)undoStack.removeFirst();
                undoStack.addLast(s.toString());
            }

            @Override public void onTextChanged(CharSequence s,int start,int before,int count){}

            @Override public void afterTextChanged(Editable e){
                if(historySuppressed)return;
                redoStack.clear();
            }
        });

        center.addView(editor,new LinearLayout.LayoutParams(-1,0,1));

        status=label("Ligne 1  |  SCHAGLK",11);
        status.setBackgroundColor(PANEL);
        center.addView(status,new LinearLayout.LayoutParams(-1,30));

        body.addView(center,new LinearLayout.LayoutParams(0,-1,0.48f));

        LinearLayout right=new LinearLayout(this);
        right.setOrientation(LinearLayout.VERTICAL);
        right.setBackgroundColor(BG);

        TextView lt=label("● LIVE PREVIEW",13);
        lt.setTextColor(BLUE);
        right.addView(lt,new LinearLayout.LayoutParams(-1,42));

        live=new WebView(this);
        live.setBackgroundColor(Color.WHITE);
        live.getSettings().setJavaScriptEnabled(true);
        live.getSettings().setDomStorageEnabled(true);
        right.addView(live,new LinearLayout.LayoutParams(-1,0,0.52f));

        right.addView(label("TERMINAL",13),new LinearLayout.LayoutParams(-1,40));

        terminalOutput=label("SCHAGLK TERMINAL\n$ ",12);
        terminalOutput.setTypeface(Typeface.MONOSPACE);
        terminalOutput.setGravity(Gravity.TOP|Gravity.START);
        terminalOutput.setBackgroundColor(Color.rgb(9,14,20));
        right.addView(terminalOutput,new LinearLayout.LayoutParams(-1,0,0.38f));

        commandInput=new EditText(this);
        commandInput.setSingleLine(true);
        commandInput.setTextColor(TEXT);
        commandInput.setHintTextColor(Color.GRAY);
        commandInput.setHint("$ commande");
        commandInput.setTypeface(Typeface.MONOSPACE);
        commandInput.setImeOptions(EditorInfo.IME_ACTION_DONE);
        commandInput.setOnEditorActionListener((v,a,e)->{
            command(commandInput.getText().toString().trim());
            commandInput.setText("");
            return true;
        });
        right.addView(commandInput,new LinearLayout.LayoutParams(-1,52));

        body.addView(right,new LinearLayout.LayoutParams(0,-1,0.32f));
        root.addView(body,new LinearLayout.LayoutParams(-1,0,1));
        setContentView(root);
    }

    void setEditorTextFromHistory(String text){
        historySuppressed=true;
        editor.setText(text);
        editor.setSelection(text.length());
        historySuppressed=false;
    }

    void undo(){
        if(undoStack.isEmpty()){
            out("UNDO: rien à annuler");
            return;
        }

        String current=editor.getText().toString();
        String previous=undoStack.removeLast();

        if(redoStack.size()>=MAX_HISTORY)redoStack.removeFirst();
        redoStack.addLast(current);

        setEditorTextFromHistory(previous);
        out("UNDO: OK");
    }

    void redo(){
        if(redoStack.isEmpty()){
            out("REDO: rien à rétablir");
            return;
        }

        String current=editor.getText().toString();
        String next=redoStack.removeLast();

        if(undoStack.size()>=MAX_HISTORY)undoStack.removeFirst();
        undoStack.addLast(current);

        setEditorTextFromHistory(next);
        out("REDO: OK");
    }

    void ensureStarter(){
        File f=new File(workspace,"index.html");
        if(!f.exists()) write(f,
            "<!doctype html>\n<html>\n<head>\n<meta name='viewport' content='width=device-width'>\n<title>SCHAGLK</title>\n<style>body{font-family:sans-serif;padding:25px;background:#eef3f8}button{padding:14px;border:0;border-radius:10px}</style>\n</head>\n<body><h1>SCHAGLK LIVE</h1><p>Projet fonctionnel.</p><button onclick=\"document.getElementById('x').innerText='TEST OK'\">TEST</button><h2 id='x'></h2></body>\n</html>");
    }

    void refreshFiles(){
        if(filesPanel==null)return;
        ScrollView sv=(ScrollView)filesPanel.getChildAt(1);
        LinearLayout c=(LinearLayout)sv.getChildAt(0);
        c.removeAllViews();
        addTree(workspace,c,"");
    }

    void addTree(File dir,LinearLayout parent,String prefix){
        File[] fs=dir.listFiles();
        if(fs==null)return;
        Arrays.sort(fs,(a,b)->a.getName().compareToIgnoreCase(b.getName()));
        for(File f:fs){
            TextView t=label((f.isDirectory()?"📁 ":"📄 ")+prefix+f.getName(),12);
            t.setOnClickListener(v->{
                if(f.isDirectory()){
                    addTree(f,parent,prefix+"  ");
                }else openFile(f);
            });
            t.setOnLongClickListener(v->{fileMenu(f);return true;});
            parent.addView(t);
        }
    }

    void openFile(File f){
        if(!f.exists())return;
        currentFile=f;
        if(!openFiles.contains(f))openFiles.add(f);
        currentTab=openFiles.indexOf(f);

        historySuppressed=true;
        editor.setText(read(f));
        historySuppressed=false;
        undoStack.clear();
        redoStack.clear();

        refreshTabs();
        if(f.getName().endsWith(".html")||f.getName().endsWith(".htm"))preview();
        status.setText("  "+f.getAbsolutePath());
    }

    void refreshTabs(){
        tabs.removeAllViews();
        for(File f:openFiles){
            Button b=btn(f.getName());
            b.setOnClickListener(v->openFile(f));
            tabs.addView(b,new LinearLayout.LayoutParams(0,48,1));
        }
    }

    void save(){
        if(currentFile==null)return;
        write(currentFile,editor.getText().toString());
        preview();
        out("SAVED: "+currentFile.getName());
    }

    void preview(){
        live.loadDataWithBaseURL(null,editor.getText().toString(),"text/html","UTF-8",null);
        out("LIVE: preview actualisé");
    }

    void command(String c){
        if(c.length()==0)return;
        out("$ "+c);
        try{
            if(c.equals("help")){
                out("help ls pwd clear cat touch mkdir rm preview save open files");
            }else if(c.equals("pwd")){
                out(workspace.getAbsolutePath());
            }else if(c.equals("ls")){
                File[] fs=workspace.listFiles();
                if(fs!=null)for(File f:fs)out((f.isDirectory()?"DIR ":"FILE ")+f.getName());
            }else if(c.equals("clear")){
                terminalOutput.setText("");
            }else if(c.equals("preview")){
                preview();
            }else if(c.equals("save")){
                save();
            }else if(c.equals("files")){
                refreshFiles();
            }else if(c.startsWith("cat ")){
                out(read(new File(workspace,c.substring(4).trim())));
            }else if(c.startsWith("touch ")){
                File f=new File(workspace,c.substring(6).trim());
                if(!f.exists())write(f,"");
                refreshFiles();
            }else if(c.startsWith("mkdir ")){
                new File(workspace,c.substring(6).trim()).mkdirs();
                refreshFiles();
            }else if(c.startsWith("rm ")){
                deleteSafe(new File(workspace,c.substring(3).trim()));
                refreshFiles();
            }else if(c.startsWith("open ")){
                openFile(new File(workspace,c.substring(5).trim()));
            }else{
                out("Commande interne inconnue. Tape help.");
            }
        }catch(Exception e){out("ERROR: "+e.getMessage());}
    }

    void createFileDialog(){
        final EditText e=new EditText(this);
        e.setHint("nom.ext");
        new AlertDialog.Builder(this).setTitle("Nouveau fichier").setView(e)
            .setPositiveButton("Créer",(d,w)->{
                String n=e.getText().toString().trim();
                if(!n.isEmpty()){File f=new File(workspace,n);write(f,"");openFile(f);refreshFiles();}
            }).setNegativeButton("Annuler",null).show();
    }

    void createFolderDialog(){
        final EditText e=new EditText(this);
        e.setHint("nom");
        new AlertDialog.Builder(this).setTitle("Nouveau dossier").setView(e)
            .setPositiveButton("Créer",(d,w)->{
                String n=e.getText().toString().trim();
                if(!n.isEmpty()){new File(workspace,n).mkdirs();refreshFiles();}
            }).setNegativeButton("Annuler",null).show();
    }

    void findDialog(){
        final EditText e=new EditText(this);
        e.setHint("texte à rechercher");
        new AlertDialog.Builder(this).setTitle("Recherche").setView(e)
            .setPositiveButton("Chercher",(d,w)->{
                String q=e.getText().toString();
                int p=editor.getText().toString().indexOf(q);
                if(p>=0){editor.requestFocus();editor.setSelection(p,p+q.length());}
                else out("Recherche: introuvable");
            }).setNegativeButton("Annuler",null).show();
    }

    void fileMenu(File f){
        String[] a={"Ouvrir","Supprimer","Renommer"};
        new AlertDialog.Builder(this).setTitle(f.getName()).setItems(a,(d,i)->{
            if(i==0&&!f.isDirectory())openFile(f);
            if(i==1){deleteSafe(f);refreshFiles();}
            if(i==2)renameDialog(f);
        }).show();
    }

    void renameDialog(File f){
        final EditText e=new EditText(this);
        e.setText(f.getName());
        new AlertDialog.Builder(this).setTitle("Renommer").setView(e)
            .setPositiveButton("OK",(d,w)->{
                String n=e.getText().toString().trim();
                if(!n.isEmpty())f.renameTo(new File(f.getParentFile(),n));
                refreshFiles();
            }).setNegativeButton("Annuler",null).show();
    }

    void ai(){
        new AlertDialog.Builder(this)
            .setTitle("SCHAGLK AI")
            .setMessage("Centre IA du projet.\n\nGénération • analyse • correction • explication • modifications multi-fichiers • diagnostics • assistance build.\n\nLe moteur IA distant/local doit être branché séparément.")
            .setPositiveButton("OK",null).show();
    }

    void out(String s){
        terminalOutput.append("\n"+s);
    }

    void write(File f,String s){
        try{
            File p=f.getParentFile();
            if(p!=null)p.mkdirs();
            FileWriter w=new FileWriter(f);
            w.write(s);
            w.close();
        }catch(Exception e){out("WRITE ERROR: "+e.getMessage());}
    }

    String read(File f){
        try{
            BufferedReader r=new BufferedReader(new FileReader(f));
            StringBuilder s=new StringBuilder();
            String l;
            while((l=r.readLine())!=null)s.append(l).append('\n');
            r.close();
            return s.toString();
        }catch(Exception e){return "";}
    }

    void deleteSafe(File f){
        if(!f.getAbsolutePath().startsWith(workspace.getAbsolutePath()))return;
        if(f.isDirectory()){
            File[] fs=f.listFiles();
            if(fs!=null)for(File x:fs)deleteSafe(x);
        }
        f.delete();
    }
}
