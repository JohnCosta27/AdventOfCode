import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
class day5 {

    public static void main(String[] args) {

        File inputs = new File("input.txt");
        try {

            Scanner in = new Scanner(inputs);
            String[] input = new String[884];

            for (int i = 0; i < 884; i++) input[i] = in.nextLine();

            int highest = 0;
            int lowest = 99999999;

            ArrayList<Integer> seatIDs = new ArrayList<Integer>();

            for (String line : input) {

                int row = binaryConvertion(line.substring(0, line.length() - 3), 'B');
                int collumn = binaryConvertion(line.substring(line.length() - 3), 'R');
                
                int calculation = row * 8 + collumn;
                if (calculation > highest) highest = calculation;
                else if (calculation < lowest) lowest = calculation;

                seatIDs.add(calculation);

            }

            for (int i = lowest; i <= highest; i++) {

                if (seatIDs.contains(i) == false) {
                    System.out.println(i);
                    break;
                }

            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        

    }

    public static int binaryConvertion(String givenInputs, char one) {
        int counter = 0;
        for (int i = givenInputs.length() - 1; i >= 0; i--) {
            if (givenInputs.charAt(i) == one) {
                counter += Math.pow(2, givenInputs.length() - i - 1);
            }
        }
        return counter;
    }

}