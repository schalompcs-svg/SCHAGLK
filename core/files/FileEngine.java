package com.schaglk.studio;
import java.io.*;
import java.nio.file.*;
import java.util.*;

public final class FileEngine {
    private final File root;

    public FileEngine(File root) {
        this.root = root;
        root.mkdirs();
    }

    public boolean inside(File f) {
        try {
            String r = root.getCanonicalPath();
            String p = f.getCanonicalPath();
            return p.equals(r) || p.startsWith(r + File.separator);
        } catch(Exception e) { return false; }
    }

    public List<File> list(File dir) {
        File[] a = dir.listFiles();
        if(a == null) return Collections.emptyList();
        Arrays.sort(a, (x,y)->x.getName().compareToIgnoreCase(y.getName()));
        return Arrays.asList(a);
    }

    public String read(File f) throws IOException {
        return Files.readString(f.toPath());
    }

    public void write(File f,String text) throws IOException {
        if(!inside(f)) throw new SecurityException("Path outside workspace");
        File p=f.getParentFile();
        if(p!=null)p.mkdirs();
        Files.writeString(f.toPath(),text);
    }

    public void mkdir(File f) {
        if(inside(f)) f.mkdirs();
    }

    public void delete(File f) throws IOException {
        if(!inside(f)) throw new SecurityException("Path outside workspace");
        if(f.isDirectory()) {
            File[] a=f.listFiles();
            if(a!=null) for(File x:a) delete(x);
        }
        Files.deleteIfExists(f.toPath());
    }
}
