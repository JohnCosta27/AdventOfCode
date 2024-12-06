import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;

import javax.print.attribute.standard.MediaSize.Other;

class day16 {
    
    public static void main(String[] args) {
        
        try {
            
            File inputFile = new File("input.txt");
            Scanner in = new Scanner(inputFile);
            List<String> input = new ArrayList<>();
            
            while (in.hasNext()) input.add(in.nextLine());
            
            List<String> fields = input.subList(0, input.indexOf("your ticket:") - 1);
            String ticket = input.get(input.indexOf("your ticket:") + 1);
            List<String> otherTickets = input.subList(input.indexOf("nearby tickets:") + 1, input.size());
            
            HashMap<Integer, Integer> ranges = new HashMap<>();
            
            List<Field> formattedFields = new ArrayList<>();
            
            for (String field : fields) {
                
                //Part 1 uses the hasmap, part 2 doesnot
                String[] currentRanges = field.substring(field.indexOf(":") + 2).split(" or ");
                String[] currentUpperAndLower = currentRanges[0].split("-");
                ranges.put(Integer.parseInt(currentUpperAndLower[0]), Integer.parseInt(currentUpperAndLower[1]));
                int[] range1 = {Integer.parseInt(currentUpperAndLower[0]), Integer.parseInt(currentUpperAndLower[1])};  
                
                currentUpperAndLower = currentRanges[1].split("-");
                ranges.put(Integer.parseInt(currentUpperAndLower[0]), Integer.parseInt(currentUpperAndLower[1]));
                int[] range2 = {Integer.parseInt(currentUpperAndLower[0]), Integer.parseInt(currentUpperAndLower[1])};
                
                String category = field.substring(0, field.indexOf(":"));
                
                formattedFields.add(new Field(category, range1, range2));
                
            }
            
            long errorRate = 0;
            List<Integer> toRemove = new ArrayList<>();
            
            for (String value : otherTickets) {
                
                String[] values = value.split(",");
                int[] singleTicketValues = Arrays.stream(values).mapToInt(Integer::parseInt).toArray();
                
                for (int singleValue : singleTicketValues) {
                    boolean valid = false;
                    for (int lower : ranges.keySet()) {
                        int upper = ranges.get(lower);
                        if (singleValue >= lower && singleValue <= upper) {
                            valid = true;
                            break;
                        }
                    }
                    
                    if (!valid) {
                        toRemove.add(otherTickets.indexOf(value));
                        errorRate += singleValue;
                    }
                }
                
            }
            
            List<String> newOtherTickets = new ArrayList<>();
            for (int i = 0; i < otherTickets.size(); i++) {
                if (!toRemove.contains(i)) newOtherTickets.add(otherTickets.get(i));
            }
            
            HashMap<Integer, List<Field>> possibleCombinations = new HashMap<>();
            for (Field f : formattedFields) possibleCombinations.put(formattedFields.indexOf(f), new ArrayList<>());
            
            for (int i = 0; i < newOtherTickets.size(); i++) {
                
                String[] firstValues = newOtherTickets.get(i).split(",");
                
                for (int j = 0; j < firstValues.length; j++) {
                    
                    int currentValue = Integer.parseInt(firstValues[j]);
                    List<Field> possible = new ArrayList<>();
                    
                    for (Field f : formattedFields) {
                        
                        if (i == 0) {
                            
                            if (f.range1[0] <= currentValue && f.range1[1] >= currentValue ||
                            f.range2[0] <= currentValue && f.range2[1] >= currentValue) {
                                possibleCombinations.get(j).add(f);
                            }
                            
                        } else {
                            
                            //Compare to this field;
                            if (f.range1[0] <= currentValue && f.range1[1] >= currentValue ||
                            f.range2[0] <= currentValue && f.range2[1] >= currentValue) {
                                possible.add(f);
                            }
                            
                        }
                        
                    }
                    
                    //Compare withoutDuplicate and "possible"
                    
                    if (i != 0) {
                        
                        List<Field> newList = new ArrayList<>();
                        for (Field f : possible) if (possibleCombinations.get(j).contains(f) && possible.contains(f)) {
                            newList.add(f);
                        }
                        
                        possibleCombinations.put(j, newList);
                        
                    }
                    
                }
            }
            
            //Part 2
            
            boolean done = false;
            
            while (!done) {
            
                for (int i : possibleCombinations.keySet()) {
                    
                    if (possibleCombinations.get(i).size() == 1) {
                        Field knownField = possibleCombinations.get(i).get(0);
                        for (int j = 0; j < possibleCombinations.size(); j++) {
                            
                            if (i != j && possibleCombinations.get(j).size() > 1) {
                                possibleCombinations.get(j).remove(knownField);
                            }
                            
                        }
                    }
                    
                } 

                done = true;
                for (int i : possibleCombinations.keySet()) {

                    if (possibleCombinations.get(i).size() != 1) done = false;

                }

            }
            
            long multiplication = 1;
            String[] myTicket = ticket.split(",");

            for (int i : possibleCombinations.keySet()) {
                Field currentField = possibleCombinations.get(i).get(0);
                if (currentField.name.contains("departure")) {
                    multiplication *= Long.parseLong(myTicket[i]);
                }
            }
            
            System.out.println("Part 1: " + errorRate);
            System.out.println("Part 2: " + multiplication);

        } catch (Exception e) {
            System.out.println(e);
        }
        
    }
    
}

class Field {
    
    public String name;
    public int[] range1;
    public int[] range2;
    public int col = -1;
    
    public Field(String name, int[] range1, int[] range2) {
        this.name = name;
        this.range1 = range1;
        this.range2 = range2;
    }
    
    public String toString() {
        return "Category: " + name + " | Range 1: " + range1[0] + "-" + range1[1] + " | Range 2: " + range2[0] + "-" + range2[1];
    }
    
}