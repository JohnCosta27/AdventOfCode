import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.ArrayList;

class day7 {
    
    public static HashMap<String, ArrayList<BagInfo>> map = new HashMap<>();
    
    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            String[] inputs = new String[594];
            
            for (int i = 0; i < 594; i++) {
                inputs[i] = in.nextLine();
            }
            
            for (String bag : inputs) {
                
                String[] bags = bag.split(" bags contain ");
                String outerBag = bags[0];
                String innerBag = bags[1];
                
                innerBag = innerBag.replace("bags", "").replace("bag", "");
                innerBag = innerBag.substring(0, innerBag.length() - 2);
                
                if (innerBag.equals("no other")) {
                    map.put(outerBag, new ArrayList<BagInfo>());
                } else {
                    
                    String[] Innerbags = innerBag.split(" , ");
                    ArrayList<BagInfo> innerBagList = new ArrayList<>();
                    
                    for (String innerbag : Innerbags) {
                        BagInfo current = new BagInfo();
                        current.quantity = Integer.parseInt(innerbag.substring(0, 1));
                        current.bag = innerbag.substring(2);
                        
                        innerBagList.add(current);
                    }
                    map.put(outerBag, innerBagList);
                }
                
            }
            
            int sum = 0;
            //Part 1 solution
            /*for (String bag : map.keySet()) {
                if (isBagInside(bag, "shiny gold")) {
                    sum++;
                };
            }*/
            
            //Part 2 solution
            
            //System.out.println(map);
            
            System.out.println(howManyBags("shiny gold") - 1);
            //System.out.println(sum);
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }
    
    public static int howManyBags(String bagName) {
        
        ArrayList<BagInfo> innerBags = map.get(bagName);
        if (innerBags.size() == 0) 
            return 1;
        
        int total = 1;
        for (BagInfo innerbag : innerBags) {
            total += (innerbag.quantity * howManyBags(innerbag.bag));
        }

        return total;
        
    }
    
    public static boolean isBagInside(String bagName, String searchBag) {
        
        ArrayList<BagInfo> innerBags = map.get(bagName);        
        
        if (innerBags.size() != 0) {
            
            for (BagInfo innerbag : innerBags) {
                if (innerbag.bag.equals(searchBag)) return true;
            }
            
            for (BagInfo innerbag : innerBags) {
                //Don't return to early, my god this took me ages.
                boolean idkwhattocallthis = isBagInside(innerbag.bag, searchBag);
                if (idkwhattocallthis) return true;
            }
            
        } else {
            return false;
        }
        return false;
    }
    
}

class BagInfo {
    public int quantity;
    public String bag;
    public String toString() {
        return "Quantity: " + quantity + " | BagName: " + bag;
    }
}
