import java.util.Scanner;
import java.io.File;
import java.math.BigInteger;

public class day18 {
    
    public static void main(String[] args) {
        
        try {
            
            File inputFile = new File("input.txt");
            Scanner in = new Scanner(inputFile);
            long total1 = 0;
            long total2 = 0;
            
            while (in.hasNext()) {
                
                String expression = in.nextLine();
                total1 += recursive(expression);
                
            }
            
            System.out.println("Total: " + total1);
            
        } catch (Exception e) {
            System.out.println(e);
        }
        
    }
    
    public static long recursive(String expression) {
        
        System.out.println(expression);
        
        int openIndex = -1;
        int closeIndex = 0;
        int count = 0;
        
        for (int i = 0; i < expression.length(); i++) {
            
            char check = expression.charAt(i);
            if (check == '(' && count == 0) {
                count = 1;
                openIndex = i;
            } else if (check == '(' && count != 0) {
                count++;
            } else if (check == ')' && count > 1) {
                count--;
            } else if (check == ')' && count == 1) {
                closeIndex = i;
                count = 0;
                long solved = recursive(expression.substring(openIndex + 1, closeIndex));
                expression = expression.substring(0, openIndex) + solved + expression.substring(closeIndex + 1);
            }
            
        }
        
        if (openIndex == -1) {
            //return solve(expression);
            //Part 2:
            return part2(expression);
        } else {
            return recursive(expression);
        }
        
    }
    
    public static long part2(String expression) {
        
        expression = expression.replace("(", "");
        expression = expression.replace(")", "");
        expression = expression.replace(" ", "");
        
        if (expression.contains("+") && expression.contains("*")) {
            
            String[] split = expression.split("[*]");
            long total = 1;
            
            for (String s : split) {
                total *= solve(s);
            }
            
            return total;
            
        } else {
            return solve(expression);
        }
        
    }
    
    public static long solve(String expression) {
        
        expression = expression.replace("(", "");
        expression = expression.replace(")", "");
        expression = expression.replace(" ", "");
        
        int loops = 0;
        //Looks bad but i think its faster than some REGEX or something,
        //plus its needed for iteration
        loops += expression.length() - expression.replace("+", "").length();
        loops += expression.length() - expression.replace("*", "").length();
        
        if (loops == 0) return Long.parseLong(expression);

        long total = 0;
        for (int i = 0; i < loops - 1; i++) {
            
            int indexRest = 0;
            int currentIndex = 0;
            for (int j = 0; j < expression.length(); j++) {
                if (!Character.isDigit(expression.charAt(j))) {
                    if (currentIndex == 0) {
                        currentIndex = j;
                    } else {
                        indexRest = j;
                        break;
                    }
                }
            }
            
            String currentExpression = expression.substring(0, indexRest);
            String[] split = currentExpression.split("[+*/-]");
            long left = Long.parseLong(split[0]);
            long right = Long.parseLong(split[1]);
            
            char operation = expression.charAt(currentIndex);
            
            long currentTotal = 0;
            
            if (operation == '+') {
                currentTotal = left + right;
            } else if (operation == '-') {
                currentTotal = left - right;
            } else if (operation == '*') {
                currentTotal = left * right;
            } else if (operation == '/') {
                currentTotal = left / right;
            }
            
            expression = currentTotal + expression.substring(indexRest);
            
        }
        
        int index = 0;
        for (int i = 0; i < expression.length(); i++) {
            if (!Character.isDigit(expression.charAt(i))) {
                index = i;
                break;
            }
        }
        
        String[] split = expression.split("[+*]");
        long left = Long.parseLong(split[0]);
        long right = Long.parseLong(split[1]);
        char operation = expression.charAt(index);
        
        if (operation == '+') {
            total = left + right;
        } else if (operation == '*') {
            total = left * right;
        }
        
        return total;
        
    }
    
}