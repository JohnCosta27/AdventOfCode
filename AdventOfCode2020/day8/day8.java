import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;

class day8 {
    
    public static void main(String[] args) {
        
        File myFile = new File("input.txt");
        try {
            
            Scanner in = new Scanner(myFile);
            ArrayList<Instruction> instructions = new ArrayList<>();
            
            while (in.hasNext()) {
                String[] split = in.nextLine().split(" ");
                Instruction current = new Instruction(split[0], Integer.parseInt(split[1]), false);
                instructions.add(current);
            }
            
            boolean done = false;
            int currentChangingInstruction = 0;
            ArrayList<Integer> checked = new ArrayList<>();

            while (!done) {
                
                while (instructions.get(currentChangingInstruction).instruction.equals("acc") || checked.contains(currentChangingInstruction)) {
                    
                    currentChangingInstruction++;
                    
                }

                checked.add(currentChangingInstruction);
                Instruction currentChange = instructions.get(currentChangingInstruction);
                
                if (currentChange.instruction.equals("jmp")) currentChange.instruction = "nop";
                else currentChange.instruction = "jmp";
                instructions.set(currentChangingInstruction, currentChange);
                
                for (Instruction i : instructions) System.out.println(i);
                
                int acc = 0;
                int instructionIndex = 0;
                Instruction currentInstruction = instructions.get(instructionIndex);
                
                while (currentInstruction.ran == false && done == false) {
                    instructions.set(instructionIndex, new Instruction(currentInstruction.instruction, currentInstruction.arg, true));
                    
                    if (currentInstruction.instruction.equals("acc")) {
                        acc += currentInstruction.arg;
                        instructionIndex++;
                    } else if (currentInstruction.instruction.equals("jmp")) {
                        
                        if (currentInstruction.arg + instructionIndex >= 0 && currentInstruction.arg + instructionIndex <= instructions.size()) {
                            instructionIndex += currentInstruction.arg;
                        } else {
                            instructionIndex = instructions.size() % currentInstruction.arg;
                        }
                        
                    } else {
                        instructionIndex++;
                    }
                    
                    if (instructionIndex == instructions.size()) {
                        done = true;
                        System.out.println("Acc: " + acc);
                    } else {
                        currentInstruction = instructions.get(instructionIndex);
                    }

                }

                if (currentChange.instruction.equals("jmp")) currentChange.instruction = "nop";
                else currentChange.instruction = "jmp";
                instructions.set(currentChangingInstruction, currentChange);
                
                for (int i = 0; i < instructions.size(); i++) {
                    Instruction changeRan = instructions.get(i);
                    changeRan.ran = false;
                    instructions.set(i, changeRan);
                }
                
            }
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        
    }
    
}

class Instruction {
    public String instruction;
    public int arg;
    public boolean ran;
    
    public Instruction(String instruction, int arg, boolean ran) {
        this.instruction = instruction;
        this.arg = arg;
        this.ran = ran;
    }
    
    public String toString() {
        return "Instruction : " + this.instruction + " | Arg: " + this.arg + " | Ran: " + this.ran;
    }
    
}