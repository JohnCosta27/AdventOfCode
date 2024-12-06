import java.util.ArrayList;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class day4 {
    
    public static void main(String[] args) {
        
        try {
            
            File myFile = new File("input.txt");
            Scanner in = new Scanner(myFile);
            
            ArrayList<String> passports = new ArrayList<String>();
            String line = "";
            String input = "";

            while (in.hasNext()) {
                input = "";
                input = in.nextLine();
                if (input.length() == 0) {
                    passports.add(line);
                    line = "";
                } else {
                    line += input;
                }
            }
            
            passports.add(input);

            int valid = 0;

            for (String current : passports) {

                String currentNoSpace = current.replaceAll("\\s","");

                String[] fields = currentNoSpace.split(":");
                int counter = 0;

                String currentField = "";

                for (int i = 0; i < fields.length - 1; i++) {

                    currentField = fields[i].substring(fields[i].length() - 3);

                    System.out.println("Next value: " + fields[i + 1]);
                    String value = "";
                    try {
                        value = fields[i + 1].substring(0, fields[i + 1].length() - 3);
                    } catch (Exception e) {
                        value = "";
                    }
                    if (i == fields.length - 2) {
                        value = fields[i + 1];
                    }
                    
                    System.out.println(currentField);
                    System.out.println(value);

                    if (currentField.equals("hcl")) {

                        String HEX_PATTERN = "^#([A-Fa-f0-9]{6})$";
                        if(value.matches(HEX_PATTERN)) counter++;

                    } else if (currentField.equals("pid")) {

                        String DIGITS_PATTERN = "\\d+";
                        if (value.matches(DIGITS_PATTERN) && value.length() == 9) counter++;

                    } else if (currentField.equals("ecl")) {

                        if (value.equals("amb") || value.equals("blu") || value.equals("brn") || value.equals("gry") 
                        || value.equals("grn") || value.equals("hzl") || value.equals("oth")) counter++;

                    } else if (currentField.equals("eyr")) {

                        String DIGITS_PATTERN = "\\d+";
                        if (value.matches(DIGITS_PATTERN)) {
                            int year = Integer.parseInt(value);
                            if (year >= 2020 && year <= 2030) counter++;
                        }

                    } else if (currentField.equals("hgt")) {

                        String DIGITS_PATTERN = "\\d+";
                        if (value.substring(0, value.length() - 2).matches(DIGITS_PATTERN)) {
                            if (value.substring(value.length() - 2, value.length()).equals("in")) {

                                int num = Integer.parseInt(value.substring(0, value.length() - 2));
                                if (num >= 59 && num <= 76) counter++;

                            } else if (value.substring(value.length() - 2, value.length()).equals("cm")) {
                                int num = Integer.parseInt(value.substring(0, value.length() - 2));
                                if (num >= 150 && num <= 193) counter++;
                            }
                        }

                    } else if (currentField.equals("byr")) {

                        String DIGITS_PATTERN = "\\d+";
                        if (value.matches(DIGITS_PATTERN)) {
                            int year = Integer.parseInt(value);
                            if (year >= 1920 && year <= 2002) counter++;
                        }

                    } else if (currentField.equals("iyr")) {

                        String DIGITS_PATTERN = "\\d+";
                        if (value.matches(DIGITS_PATTERN)) {
                            int year = Integer.parseInt(value);
                            if (year >= 2010 && year <= 2020) counter++;
                        }

                    }

                }

                if (counter == 7) valid++;
                counter = 0;

            }

            System.out.println("Valid: " + valid);

        } catch (FileNotFoundException e) {
            System.out.println(e);
        }
        
    }
    
}

