import java.io.File;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class day14 {
    
    public static void main(String[] args) {
        
        try {
            
            File inputFile = new File("input.txt");
            Scanner in = new Scanner(inputFile);
            
            HashMap<Long, Long> memory = new HashMap<>();
            String mask = "";
            
            while (in.hasNext()) {
                
                String[] line = in.nextLine().split(" = ");
                if (line[0].equals("mask")) {
                    mask = line[1];
                    System.out.println("Mask: " + mask);
                } else {
                    int address = Integer.parseInt(line[0].substring(line[0].indexOf("[") + 1, line[0].indexOf("]")));
                    long value = Long.parseLong(line[1]);
                    //memory.put(address, maskedValue(mask, value));
                    long[] addresses = maskedAddresses(mask, address);
                    for (long a : addresses) {
                        System.out.printf("Address: %d | Value: %d \n", a, value);
                        memory.put(a, value);
                    }
                }
                
            }
            
            long sumLong = 0;
            
            for (long key : memory.keySet()) {
                sumLong += memory.get(key);
            }
            
            System.out.println("Answer: " + sumLong);
            
        } catch (Exception e) {
            System.out.println(e);
        }
        
    }
    
    static long maskedValue(String mask, int value) {
        
        String binaryString = Integer.toBinaryString(value);
        
        while (binaryString.length() != 36) binaryString = "0" + binaryString;
        
        String returnString = new String();
        System.out.println("Binary String: " + binaryString);
        for (int i = binaryString.length() - 1; i >= 0; i--) {
            
            if (binaryString.charAt(i) != mask.charAt(i) && mask.charAt(i) != 'X') {
                returnString = mask.charAt(i) + returnString;
            } else {
                returnString = binaryString.charAt(i) + returnString;
            }
            
        }
        
        System.out.println("Return String: " + returnString);
        
        return toDenary(returnString);
        
    }
    
    static long[] maskedAddresses(String mask, int value) {
        String binaryString = Integer.toBinaryString(value);
        
        while (binaryString.length() != 36) binaryString = "0" + binaryString;
        
        String returnString = new String();
        ArrayList<Integer> xlist = new ArrayList<>();
        System.out.println("Binary String: " + binaryString);
        for (int i = binaryString.length() - 1; i >= 0; i--) {
            
            if (mask.charAt(i) == 'X') xlist.add(i);
            
            if (binaryString.charAt(i) != mask.charAt(i) && mask.charAt(i) != '0') {
                returnString = mask.charAt(i) + returnString;
            } else {
                returnString = binaryString.charAt(i) + returnString;
            }
            
        }
        
        System.out.println("Return string: " + returnString);

        String[] binaryStrings = new String[(int) Math.pow(2, xlist.size())];
        
        for (int i = 0; i < Math.pow(2, xlist.size()); i++) {
            
            String currentI = Integer.toBinaryString(i);
            while (currentI.length() < xlist.size()) currentI = "0" + currentI;

            String newAddress = returnString;
            for (int j = 0; j < currentI.length(); j++) {
                newAddress = newAddress.replaceFirst(Pattern.quote("X"), Matcher.quoteReplacement(Character.toString(currentI.charAt(j))));
            }
            
            System.out.println("New address: " + newAddress);
            binaryStrings[i] = newAddress;
            
        }
        
        long[] newAddresses = new long[binaryStrings.length];
        for (int i = 0; i < newAddresses.length; i++) {
            newAddresses[i] = toDenary(binaryStrings[i]);
        }
        
        return newAddresses;

    }
    
    static long toDenary(String binary) {
        long value = 0;
        for (int i = 0; i < binary.length(); i++) {
            if (binary.charAt(i) == '1') {
                value += Math.pow(2, (35 - i));
            }
        }
        return value;
    }
    
}
