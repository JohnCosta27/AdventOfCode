import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class day6 {

    public static void main(String[] args) {

        File myFile = new File("input.txt");
        try {

            Scanner in = new Scanner(myFile);
            ArrayList<String> inputs = new ArrayList<String>();
            String line = "";
            String input = "";

            while (in.hasNext()) {
                input = "";
                input = in.nextLine();
                if (input.length() == 0) {
                    inputs.add(line.substring(0, line.length() - 1));
                    line = "";
                } else {
                    line += input + ",";
                }
            }
            
            inputs.add(line.substring(0, line.length() - 1));
            int sum = 0;

            for (String current : inputs) {

                HashMap<Character, Integer> map = new HashMap<>();
                String[] currentSplit = current.split(",");

                for (String single : currentSplit) {
                    for (char c : single.toCharArray()) {

                        if (map.get(c) == null) {
                            map.put(c, 1);
                        } else {
                            map.put(c, map.get(c) + 1);
                        }
 
                    }
                }

                for (char c : map.keySet()) {
                    if (map.get(c) == currentSplit.length) sum++;
                }

            }

            System.out.printf("Total sum %d", sum);

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

    }

}