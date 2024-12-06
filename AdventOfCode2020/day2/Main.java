import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
class Main {
    
    public static void main(String[] args) {
        
        try {
            
            File myFile = new File("input.txt");
            Scanner in = new Scanner(myFile);
            
            int valid = 0;
            
            for (int i = 0; i < 1000; i++) {
                
                String line = in.nextLine();
                
                String[] firstSplit = line.split(" ");
                //0 - numbers
                //1 - letter
                //2 - Password
                
                String[] boundsStr = firstSplit[0].split("-");
                int[] bounds = {Integer.parseInt(boundsStr[0]), Integer.parseInt(boundsStr[1])};
                char letter = firstSplit[1].charAt(0);
                String password = firstSplit[2];
                //int counter = 0;
                
                //Part 1 code
                /*for (char c : password.toCharArray()) {
                    if (c == letter) counter++;
                }
                
                if (counter >= bounds[0] && counter <= bounds[1]) valid++;*/
                
                //Second part code
                if ((password.charAt(bounds[0] - 1) == letter || password.charAt(bounds[1] - 1) == letter) && !(password.charAt(bounds[0] - 1) == letter && password.charAt(bounds[1] - 1) == letter)) valid++;
                
            }
            
            System.out.println(valid);
            in.close();   
            
        } catch (FileNotFoundException e) {
            System.out.println(e);
        }
        
    }
    
}