import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class day1 {

	public static void main(String[] args) {

		try {

			File myFile = new File("input.txt");
			Scanner in = new Scanner(myFile);

			int[] input = new int[200];
			for (int i = 0; i < 200; i++) {
				input[i] = Integer.parseInt(in.next());
			}

			for (int i = 0; i < 198; i++) {
				for (int j = i + 1; j < 199; j++) {
					//Following is for part1
					//if (input[i] + input[j] == 2020) {
						//System.out.println(input[i] * input[j]);
					//}
					for (int k = j + 1; k < 200; k++) {
						if (input[i] + input[j] + input[k] == 2020) {
							System.out.println(input[i] * input[j] * input[k]);
						}
					}
				}
			}

			in.close();

		} catch (FileNotFoundException e) {
			System.out.println(e);
		}

	}

}