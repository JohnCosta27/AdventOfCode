import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
class day3 {
    
    public static void main(String[] args) {
        
        try {
            
            File myFile = new File("input.txt");
            Scanner in = new Scanner(myFile);
            
            String[] trees = new String[323];
            
            int lineLength;
            
            long multiple = 1;
            int numOfTrees = 0;
            
            int x = 0;
            
            for (int i = 0; i < 323; i++) {
                trees[i] = in.nextLine();
            }
            
            lineLength = trees[0].length();
            
            /*Part 1 code
            for (String line : trees) {
                
                char current = line.charAt(x % lineLength);
                
                if (current == '#') numOfTrees++;
                x = x + 3;
                
            }
            
            */
            
            for (int dy = 1; dy < 3; dy++) {
                for (int dx = 1; dx < 8; dx = dx + 2) {
                    
                    if (!(dy == 2 && dx > 1)) {
                        numOfTrees = 0;
                        x = 0;
                        for (int i = 0; i < 323; i = i + dy) {
                            char current = trees[i].charAt(x % lineLength);
                            
                            if (current == '#') numOfTrees++;
                            x = x + dx;
                            
                        }
                        System.out.println(numOfTrees);
                        multiple *= numOfTrees;
                    }
                    
                }
            }
            
            
            System.out.println(multiple);
            
        } catch (FileNotFoundException e) {
            System.out.println(e);
        }
        
    }
    
}

