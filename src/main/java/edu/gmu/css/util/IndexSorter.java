package edu.gmu.css.util;


import java.util.Comparator;

public class IndexSorter implements Comparator<Integer> {
    private final int[] array;
    private int size;

    public IndexSorter(int [] input) {
        this.array = input;
    }

    public Integer[] createIndexArray() {
        Integer[] indexes = new Integer[array.length];
        for (int i=0; i<array.length; i++) {
            indexes[i] = i;
        }
        return indexes;
    }

    @Override
    public int compare(Integer i1, Integer i2) {
        Integer x1 = array[i1];
        Integer x2 = array[i2];
        return x1.compareTo(x2);
    }

    public int compDesc(Integer i1, Integer i2) {
        Integer x1 = array[i1];
        Integer x2 = array[i2];
        return x2.compareTo(x1);
    }

}
