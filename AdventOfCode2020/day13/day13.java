import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;

class day13 {
    
    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            
            double timestamp = Double.parseDouble(in.nextLine());
            String[] secondLine = in.nextLine().split(",");
            ArrayList<Double> buses = new ArrayList<>();

            for (String i : secondLine) {
                if (!i.equals("x")) buses.add(Double.parseDouble(i));
            }
            
            double shortestTime = Double.MAX_VALUE;
            double shortestBus = 0;

            for (double i : buses) {

                double closestTime = Math.ceil(timestamp / i) * i;
                System.out.printf("Time: %f | Closest Time: %f \n", i, closestTime);         

                if (closestTime < shortestTime) {
                    shortestTime = closestTime;
                    shortestBus = i;
                }

            }

            System.out.printf("Part 1: %f \n", (shortestTime - timestamp) * shortestBus);

            in.close();

            

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }

}