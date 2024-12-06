import java.util.ArrayList;
import java.util.HashMap;

class day15 {
    
    public static void main(String[] args) {
        
        int[] startingNumbers = {17,1,3,16,19,0};        
        ArrayList<Integer> spokenNums = new ArrayList<>();
        HashMap<Integer, Integer> seenLast = new HashMap<>();
        int lastNumber = 0;
        
        for (int i = 0; i < startingNumbers.length; i++) {
            spokenNums.add(startingNumbers[i]);
            lastNumber = startingNumbers[i];
            if (i + 1 != startingNumbers.length) {
                seenLast.put(startingNumbers[i], i + 1);
            }
        }

        while (spokenNums.size() < 30000000) {

            if (!seenLast.containsKey(lastNumber)) {
                seenLast.put(lastNumber, spokenNums.size());
                spokenNums.add(0);
                lastNumber = 0;
            } else {
                int diff = spokenNums.size() - seenLast.get(lastNumber);
                seenLast.put(lastNumber, spokenNums.size());
                lastNumber = diff;
                spokenNums.add(lastNumber);
            }

        }
        
        System.out.println("Number: " + spokenNums.get(spokenNums.size() - 1));

    }
    
}