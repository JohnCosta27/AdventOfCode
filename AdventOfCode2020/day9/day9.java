import java.util.Scanner;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;

class day9 {

    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            ArrayList<Long> nums = new ArrayList<>();
            
            while (in.hasNext()) {
                nums.add(Long.parseLong(in.nextLine()));
            }

            //final int preamble = 25;
            //int lower = 0;
            
            long target = 1309761972;

            for (int i = 0; i < nums.size() - 1; i++) {

                boolean over = false;
                long sum = 0;


                ArrayList<Long> currentSet = new ArrayList<>();

                for (int j = i; j < nums.size() && over == false; j++) {

                    sum += nums.get(j);
                    currentSet.add(nums.get(j));

                    if (sum == target) {

                        long highest = 0;
                        long lowest = Long.MAX_VALUE;

                        for (int k = 0; k < currentSet.size(); k++) {
                            long current = currentSet.get(k);
                            if (current < lowest) lowest = current;
                            if (current > highest) highest = current;
                        }

                        over = true;

                        System.out.println("Lowest: " + lowest);
                        System.out.println("highest: " + highest);

                        System.out.println(highest + lowest);
                        break;

                    } else if (sum > target) {
                        over = true;
                    }

                }

            }

            //Part 1, very inefficient code, had no time to do this one today
            //Made easier using a stack and an array to which the combination of numbers in the stack would add up to
            //Pop and remove from the stack and remove the last 25 items from array/list
            //And that would be the most efficient with an efficiency of O(n^2)? instead of O(n^3) - I think, not sure
            /*for (int currentNum = preamble; currentNum < nums.size(); currentNum++) {

                boolean adds = false;

                for (int i = currentNum - preamble; i < currentNum - 1; i++) {
                    for (int j = i + 1; j < currentNum; j++) {

                        System.out.printf("Adding %d and %d, Current Num: %d \n", nums.get(i), nums.get(j), nums.get(currentNum));

                        if (nums.get(i) + nums.get(j) == nums.get(currentNum)) {
                            adds = true;
                        }

                    }
                }

                System.out.println(adds);

                if (!adds) {
                    System.out.println(nums.get(currentNum));
                    break;
                }

            }*/

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }
    
}