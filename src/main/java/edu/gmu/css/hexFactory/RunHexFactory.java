package edu.gmu.css.hexFactory;

public class RunHexFactory {

    private static String[] yearString = {"1815", "1880", "1914", "1945", "1994"};
    private static int[] yearInt = {1815, 1880, 1914, 1945, 1994};

    public static void main(String args[]) {
        for (int y : yearInt) {
            MultiThreadHexFactory mthf = new MultiThreadHexFactory("for" + y);
            mthf.start();
        }

    }

}
