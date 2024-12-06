import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class Main {

    public static void main(String[] args) throws FileNotFoundException {

        File myFile = new File("day16.txt");
        Scanner in = new Scanner(myFile);
        int index = 1;

        while (in.hasNext()) {

            String[] input = in.nextLine().replaceAll("\\s+", "").split(":");

            Map<String, Integer> currentAunt = new HashMap<>();

            String[] secondLineSplit = input[2].split(",");
            String[] thirdLineSplit = input[3].split(",");

            currentAunt.put(input[1], Integer.parseInt(secondLineSplit[0]));
            currentAunt.put(secondLineSplit[1], Integer.parseInt(thirdLineSplit[0]));
            currentAunt.put(thirdLineSplit[1], Integer.parseInt(input[4]));

            int counter = 0;
            int part2counter = 0;

            for (String key : currentAunt.keySet()) {

                switch (key) {
                    case "children":
                        if (currentAunt.get(key) == 3) {
                            counter++;
                            part2counter++;
                        }
                        break;
                    case "cats":
                        if (currentAunt.get(key) == 7) {
                            counter++;
                        }
                        if (currentAunt.get(key) > 7) {
                            part2counter++;
                        }
                        break;
                    case "samoyeds":
                        if (currentAunt.get(key) == 2) {
                            counter++;
                            part2counter++;
                        }
                        break;
                    case "pomeranians":
                        if (currentAunt.get(key) == 3) {
                            counter++;
                        }
                        if (currentAunt.get(key) < 3) {
                            part2counter++;
                        }
                        break;
                    case "akitas":
                        if (currentAunt.get(key) == 0) {
                            counter++;
                            part2counter++;
                        }
                        break;
                    case "vizslas":
                        if (currentAunt.get(key) == 0) {
                            counter++;
                            part2counter++;
                        }
                        break;
                    case "goldfish":
                        if (currentAunt.get(key) == 5) {
                            counter++;
                        }
                        if (currentAunt.get(key) < 5) {
                            part2counter++;
                        }
                        break;
                    case "trees":
                        if (currentAunt.get(key) == 3) {
                            counter++;
                        }
                        if (currentAunt.get(key) > 3) {
                            part2counter++;
                        }
                        break;
                    case "cars":
                        if (currentAunt.get(key) == 2) {
                            counter++;
                            part2counter++;
                        }
                        break;
                    case "perfumes":
                        if (currentAunt.get(key) == 1) {
                            counter++;
                            part2counter++;
                        }
                        break;
                }

            }

            if (counter == 3) {
                System.out.printf("Part 1: %d \n", index);
            } else if (part2counter == 3) {
                System.out.printf("Part 2: %d \n", index);
            }
            index++;
        }

        in.close();

    }

}