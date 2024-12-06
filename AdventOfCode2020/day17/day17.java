import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

class day17 {
    
    public static void main(String[] args) {
        
        List<int[]> points = new ArrayList<>();
        List<int[]> pointsPart2 = new ArrayList<>();
        
        char[][] input = {{'.', '.', '#', '.', '.', '#', '.', '.'},
        {'#', '.', '#', '.', '.', '.', '#', '.'},
        {'.', '.', '#', '.', '.', '.', '.', '.'},
        {'#', '#', '.', '.', '.', '.', '#', '#'},
        {'#', '.', '.', '#', '.', '#', '#', '#'},
        {'.', '#', '.', '.', '#', '.', '.', '.'},
        {'#', '#', '#', '.', '.', '#', '.', '.'},
        {'.', '.', '.', '.', '#', '.', '.', '#'}};

        /*char[][] input = {{'.', '#', '.'},
                          {'.', '.', '#'},
                          {'#', '#', '#'}};*/
        
        //Part 1
        
        //initialise
        for (int i = 0; i < input.length; i++) {
            for (int j = 0; j < input[0].length; j++) {
                int[] newPoint = {j, i, 0, 0};
                int[] newPointPart2 = {j, i, 0, 0, 0};
                if (input[i][j] == '#') {
                    newPoint[3] = 1;
                    newPointPart2[4] = 1; 
                }
                points.add(newPoint);
                pointsPart2.add(newPointPart2);
            }
        }
        
        for (int i = 0; i < 6; i++) {
            points = step(points);
            pointsPart2 = stepPart2(pointsPart2);
        }
        
        int counter = 0;
        for (int[] p : points) {
            if (p[3] == 1) counter++;
            //System.out.printf("x: %d | y: %d | z: %d | State: %d \n", p[0], p[1], p[2], p[3]);
        }
        System.out.println("Part 1: " + counter);
        
        counter = 0;
        for (int[] p : pointsPart2) {
            if (p[4] == 1) counter++;
            //System.out.printf("x: %d | y: %d | z: %d | State: %d \n", p[0], p[1], p[2], p[3]);
        }
        System.out.println("Part 2: " + counter);
        
    }
    
    static List<int[]> step(List<int[]> points) {
        
        List<int[]> newPoints = new ArrayList<>();
        List<int[]> pointsToCheck = new ArrayList<>();

        for (int[] p : points) {
            
            int active = 0;
            
            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    for (int z = -1; z <= 1; z++) {
                        
                        if (!(x == 0 && y == 0 && z == 0)) {
                            
                            int[] potentialNeighboor = {p[0] + x, p[1] + y, p[2] + z, 0};
                            int index = contains(potentialNeighboor, points);
                            if (index != -1) {
                                int[] foundPoint = points.get(index);
                                if (foundPoint[3] == 1) {
                                    active++;
                                }
                            } else {
                                if (contains(potentialNeighboor, pointsToCheck) == -1) pointsToCheck.add(potentialNeighboor);
                            }
                            
                        }
                        
                    }
                }
            }
            
            int[] newPoint = {p[0], p[1], p[2], p[3]};
            
            if (p[3] == 1) {
                if (active != 2 && active != 3) newPoint[3] = 0;
            } else {
                if (active == 3) newPoint[3] = 1;
            }
            
            newPoints.add(newPoint);
            
        }
        
        for (int[] p : pointsToCheck) {
            
            int active = 0;
            
            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    for (int z = -1; z <= 1; z++) {
                        
                        if (!(x == 0 && y == 0 && z == 0)) {
                            
                            int[] potentialNeighboor = {p[0] + x, p[1] + y, p[2] + z, 0};
                            int index = contains(potentialNeighboor, points);
                            if (index != -1) {
                                int[] foundPoint = points.get(index);
                                if (foundPoint[3] == 1) active++;
                            }
                            
                        }
                        
                    }
                }
            }
            
            int[] newPoint = {p[0], p[1], p[2], p[3]};
            
            if (active == 3){
                newPoint[3] = 1;
                //System.out.printf("x: %d | y: %d | z: %d | State: %d \n", newPoint[0], newPoint[1], newPoint[2], newPoint[3]);
            } 
            
            newPoints.add(newPoint);
            
        }
        
        return newPoints;
        
    }
    
    static List<int[]> stepPart2(List<int[]> points) {
        
        System.out.println(points.size());

        List<int[]> newPoints = new ArrayList<>();
        List<int[]> pointsToCheck = new ArrayList<>();
        
        for (int[] p : points) {
            
            int active = 0;

            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    for (int z = -1; z <= 1; z++) {
                        for (int w = -1; w <= 1; w++) {

                            if (!(x == 0 && y == 0 && z == 0 && w == 0)) {
                                int[] potentialNeighboor = {p[0] + x, p[1] + y, p[2] + z, p[3] + w, 0};
                                int index = containsPart2(potentialNeighboor, points);
                                if (index != -1) {
                                    int[] foundPoint = points.get(index);
                                    if (foundPoint[4] == 1) active++;
                                } else {
                                    if (containsPart2(potentialNeighboor, pointsToCheck) == -1) pointsToCheck.add(potentialNeighboor);
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            
            int[] newPoint = {p[0], p[1], p[2], p[3], p[4]};
            
            if (p[4] == 1) {
                if (active != 2 && active != 3) newPoint[4] = 0;
            } else {
                if (active == 3) newPoint[4] = 1;
            }
            
            newPoints.add(newPoint);
            
        }
        
        for (int[] p : pointsToCheck) {
            
            int active = 0;
            
            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    for (int z = -1; z <= 1; z++) {
                        for (int w = -1; w <= 1; w++) {
                            if (!(x == 0 && y == 0 && z == 0 && w == 0)) {
                                
                                int[] potentialNeighboor = {p[0] + x, p[1] + y, p[2] + z, p[3] + w, 0};
                                int index = containsPart2(potentialNeighboor, points);
                                if (index != -1) {
                                    int[] foundPoint = points.get(index);
                                    if (foundPoint[4] == 1) active++;
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            
            int[] newPoint = {p[0], p[1], p[2], p[3], p[4]};
            
            if (active == 3) newPoint[4] = 1;
            newPoints.add(newPoint);
            
        }
        
        return newPoints;
        
    }
    
    static int contains(int[] p, List<int[]> points) {
        for (int[] search : points) {
            if (search[0] == p[0] && search[1] == p[1] && search[2] == p[2]) {
                return points.indexOf(search);
            }
        }
        return -1;
    }
    
    static int containsPart2(int[] p, List<int[]> points) {
        for (int[] search : points) {
            if (search[0] == p[0] && search[1] == p[1] && search[2] == p[2] && search[3] == p[3]) {
                return points.indexOf(search);
            }
        }
        return -1;
    }
    
}