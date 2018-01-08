import mmcorej.*;


class microManagerSetPath {
    public static void main( String args[] ) {
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
    /*System.exit(1);*/
    }

  }
}

