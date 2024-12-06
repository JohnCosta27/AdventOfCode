import java.util.Scanner;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

class day10 {
    
    static HashMap<ArrayList<Integer>, Long> cache = new HashMap<>();

    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            ArrayList<Integer> nums = new ArrayList<>();
            
            while (in.hasNext()) {
                nums.add(Integer.parseInt(in.nextLine()));
            }
            
            nums.add(0);

            Collections.sort(nums);
            
            nums.add(nums.get(nums.size() - 1) + 3);

            //Part 1 code
            
            int one = 0;
            int two = 0;
            int three = 0;
            
            for (int i = 1; i < nums.size(); i++) {
                
                int diff = nums.get(i) - nums.get(i - 1);
                
                if (diff == 1) {
                    one++;
                } else if (diff == 2) {
                    two++;
                } else if (diff == 3) {
                    three++;;
                }
                
            }
            
            if (nums.get(0) == 1) one++; //From the plug to the first adaptor
            three++; //Build in adaptor
            
            //System.out.printf("One: %d | Two: %d | Three: %d \n", one, two, three);
            //System.out.printf("Multiplied: %d", one * three);
            
            //System.out.println(isValid(nums, nums.size()));
            
            

            System.out.println(getSum(nums));
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }
    
    /*
        Recursive method for part 2 solution
        There is likely a method which has o(N) complexity, but seeing as this is a daily thing, and I don't have 
        all that much time this is still an elegant solution.
    */
    public static long getSum(ArrayList<Integer> nums) {
        
        long sum = 0;
        if (nums.size() == 1) {
            //System.out.println("Size 1");
            return 1;
        }

        ArrayList<Integer> newNums = new ArrayList<>(nums);

        for (int i = 1; i <= 3; i++) {

            int pointer = nums.size() - 1 - i;
            //System.out.println("Pointer: " + pointer);
            //System.out.println("DSADS: " + nums.get(pointer));
            if (pointer >= 0) {
                if (nums.get(nums.size() - 1) - nums.get(pointer) <= 3) {
                    newNums.remove(pointer + 1);

                    /*System.out.println("============SENT==========");
                    for (int c : nums) System.out.println(c);
                    System.out.println("==========================");

                    System.out.println("==========================");
                    for (int c : newNums) System.out.println(c);
                    System.out.println("==========================");*/

                    if (cache.containsKey(newNums)) {
                        sum += cache.get(newNums);
                    } else {
                        long treeSum = getSum(newNums);
                        //System.out.println("Tree sum: " + treeSum);
                        cache.put(newNums, treeSum);
                        sum += treeSum;
                    }

                }
            }

        }

        return sum;

    }
    
    public static boolean isValid(ArrayList<Integer> nums) {
        for (int i = 1; i < nums.size(); i++) {
            int diff = nums.get(i) - nums.get(i - 1);
            if (diff > 3) return false;
        }
        return true;
    }
    
    static int nCr(int n, int r)  { 
        return fact(n) / (fact(r) * 
        fact(n - r)); 
    } 
    
    // Returns factorial of n 
    static int fact(int n) { 
        int res = 1; 
        for (int i = 2; i <= n; i++) 
        res = res * i; 
        return res; 
    } 
    
}