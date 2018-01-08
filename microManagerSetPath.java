import mmcorej.*;
import java.io.*;
import java.util.TreeSet;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.awt.image.*;
import javax.imageio.*;
import javax.swing.*;
 

public class microManagerSetPath {
    static BufferedImage bi, biFiltered;
    public static void main( String args[] ){
    /*Set the library path to directory that contains MMCoreJwrap*/
    System.setProperty("mmcorej.library.path", "C:/Program Files/Micro-Manager-1.4/");
    
    /*Create CMMCore object and get information about the object*/
    CMMCore core = new CMMCore();
    String info = core.getVersionInfo();
    System.out.println(info);
    

    
    try {
        // clear previous setup if any
        core.unloadAllDevices();
        core.loadDevice("Camera", "HamamatsuHam", "HamamatsuHam_DCAM");
        
        //core.initializeDevice("Camera");
        core.initializeAllDevices();
        
        
        core.setExposure(50);
        core.snapImage();
			
        if (core.getBytesPerPixel() == 1) {
           // 8-bit grayscale pixels
           byte[] img = (byte[])core.getImage();
           System.out.println("Image snapped, " + img.length + " pixels total, 8 bits each.");
           System.out.println("Pixel [0,0] value = " + img[0]);
        } else if (core.getBytesPerPixel() == 2){
           // 16-bit grayscale pixels
           short[] img = (short[])core.getImage();
           System.out.println("Image snapped, " + img.length + " pixels total, 16 bits each.");
           System.out.println("Pixel [0,0] value = " + img[0]);             
        } else {
           System.out.println("Dont' know how to handle images with " +
                 core.getBytesPerPixel() + " byte pixels.");             
        }
    } catch (Exception e){
        System.out.println("Exception: " + e.getMessage() + "\nExiting now."); 
    /*System.exit(1);*/
    }
    long width_ = core.getImageWidth();
    long height_ = core.getImageHeight();
    long byteDepth = core.getBytesPerPixel();

    ShortProcessor ip = new ShortProcessor((int) width_, (int)
height_);
    /*ip.setPixels(img);
    ImagePlus imp = new ImagePlus("testing.png", ip);
    FileSaver fs = new FileSaver(imp);
    fs.saveAsTiff("testing.png");*/
    


  }
}

