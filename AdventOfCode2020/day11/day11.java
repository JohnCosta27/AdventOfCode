import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class day11 {
    
    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            char[][] seats = new char[91][94];
            int index = 0;
            
            while (in.hasNext()) {
                seats[index] = in.nextLine().toCharArray();
                index++;
            }
            
            boolean stable = false;
            
            while (!stable) {
                
                //char[][] newSeats = part1(seats);
                char[][] newSeats = part2(seats);
                boolean notEqual = false;
                
                for (int i = 0; i < seats.length; i++) {
                    for (int j = 0; j < seats[0].length; j++) {
                        if (newSeats[i][j] != seats[i][j]) notEqual = true;
                    }
                }
                
                if (notEqual) {
                    seats = newSeats;
                } else {
                    stable = true;
                }
                
            }

            int occupiedSeats = 0;

            for (int i = 0; i < seats.length; i++) {
                for (int j = 0; j < seats[0].length; j++) {
                    if (seats[i][j] == '#') occupiedSeats++;
                    System.out.print(seats[i][j]);
                }
                System.out.println();
            }
            
            System.out.println("Answer: " + occupiedSeats);
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }
    
    static char[][] part1(char[][] seats) {
        
        char[][] newSeats = new char[seats.length][seats[0].length];
        
        for (int i = 0; i < seats.length; i++) {
            for (int j = 0; j < seats[0].length; j++) {
                
                int emptySeats = 0;
                int occupiedSeats = 0;
                
                if (seats[i][j] != '.') {
                    
                    for (int checkX = -1; checkX <= 1; checkX++) {
                        for (int checkY = -1; checkY <= 1; checkY++) {
                            
                            if (j + checkX >= 0 && i + checkY >= 0 && 
                            j + checkX < seats[0].length && i + checkY < seats.length &&
                            !(checkX == 0 && checkY == 0)) {
                                
                                if (seats[i + checkY][j + checkX] == 'L') emptySeats++;
                                else if (seats[i + checkY][j + checkX] == '#') occupiedSeats++;
                                
                            }
                            
                        }
                    }
                    
                    if (occupiedSeats == 0 && seats[i][j] == 'L') newSeats[i][j] = '#';
                    else if (occupiedSeats >= 4 && seats[i][j] == '#') newSeats[i][j] = 'L';
                    else newSeats[i][j] = seats[i][j];
                    
                } else newSeats[i][j] = '.';
                
            }
            
        }
        
        return newSeats;
        
    }
    
    static char[][] part2(char[][] seats) {
        
        char[][] newSeats = new char[seats.length][seats[0].length];

        for (int i = 0; i < seats.length; i++) {
            for (int j = 0; j < seats[0].length; j++) {
                
                int occupiedSeats = 0;
                
                //System.out.print(seats[i][j]);

                if (seats[i][j] != '.') {
                    for (int checkX = -1; checkX <= 1; checkX++) {
                        for (int checkY = -1; checkY <= 1; checkY++) {

                            if (!(checkX == 0 && checkY == 0)) {

                                int multipliedX = checkX;
                                int multipliedY = checkY;

                                boolean foundSeat = false;

                                while (j + multipliedX >= 0 && i + multipliedY >= 0 && j + multipliedX < seats[0].length && i + multipliedY < seats.length && foundSeat == false) {

                                    if(seats[i + multipliedY][j + multipliedX] == 'L') {
                                        foundSeat = true;
                                    } else if (seats[i + multipliedY][j + multipliedX] == '#') {
                                        occupiedSeats++;
                                        foundSeat = true;
                                    }
                                    
                                    multipliedX += checkX;
                                    multipliedY += checkY;
                                    
                                }
                            }
                            
                        }
                    }

                    //System.out.print(occupiedSeats);

                    if (occupiedSeats >= 5 && seats[i][j] == '#') newSeats[i][j] = 'L';
                    else if (occupiedSeats == 0 && seats[i][j] == 'L') newSeats[i][j] = '#';
                    else newSeats[i][j] = seats[i][j];

                } else newSeats[i][j] = '.';
            }
            //System.out.println();
        }

        return newSeats;
        
    }
    
}