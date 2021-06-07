package edu.gmu.css.util;

import ec.util.MersenneTwisterFast;

import java.util.Random;


public class MTFWrapper extends Random {

    private final MersenneTwisterFast mtf;
//    private long seed;

    public MTFWrapper() {
        this.mtf = new MersenneTwisterFast();
    }

    public MTFWrapper(Long seed) {
        super.setSeed(seed);
        this.mtf = new MersenneTwisterFast(seed);
        System.nanoTime();
    }

    public MTFWrapper(long seed) {
        super.setSeed(seed);
        this.mtf = new MersenneTwisterFast(seed);
    }

//    @Override
//    public synchronized void setSeed(long seed) {
//        this.mtf.setSeed(seed);
//    }

    @Override
    protected int next(int bits) {
        return super.next(bits);
    }

    @Override
    public void nextBytes(byte[] bytes) {
        this.mtf.nextBytes(bytes);
    }

    @Override
    public int nextInt() {
        return mtf.nextInt();
    }

    @Override
    public int nextInt(int bound) {
        return mtf.nextInt(bound);
    }

    @Override
    public long nextLong() {
        return mtf.nextLong();
    }

    @Override
    public boolean nextBoolean() {
        return mtf.nextBoolean();
    }

    @Override
    public float nextFloat() {
        return mtf.nextFloat();
    }

    @Override
    public double nextDouble() {
        return mtf.nextDouble();
    }

    @Override
    public synchronized double nextGaussian() {
        return mtf.nextGaussian();
    }

//  TODO: Write Stream api for MTF Random Wrapper. Currently unnecessary, but it is incomplete.
//
//    @Override
//    public IntStream ints(long streamSize) {
//        return super.ints(streamSize);
//    }
//
//    @Override
//    public IntStream ints() {
//        return super.ints();
//    }
//
//    @Override
//    public IntStream ints(long streamSize, int randomNumberOrigin, int randomNumberBound) {
//        return super.ints(streamSize, randomNumberOrigin, randomNumberBound);
//    }
//
//    @Override
//    public IntStream ints(int randomNumberOrigin, int randomNumberBound) {
//        return super.ints(randomNumberOrigin, randomNumberBound);
//    }
//
//    @Override
//    public LongStream longs(long streamSize) {
//        return super.longs(streamSize);
//    }
//
//    @Override
//    public LongStream longs() {
//        return super.longs();
//    }
//
//    @Override
//    public LongStream longs(long streamSize, long randomNumberOrigin, long randomNumberBound) {
//        return super.longs(streamSize, randomNumberOrigin, randomNumberBound);
//    }
//
//    @Override
//    public LongStream longs(long randomNumberOrigin, long randomNumberBound) {
//        return super.longs(randomNumberOrigin, randomNumberBound);
//    }
//
//    @Override
//    public DoubleStream doubles(long streamSize) {
//        return super.doubles(streamSize);
//    }
//
//    @Override
//    public DoubleStream doubles() {
//        return super.doubles();
//    }
//
//    @Override
//    public DoubleStream doubles(long streamSize, double randomNumberOrigin, double randomNumberBound) {
//        return super.doubles(streamSize, randomNumberOrigin, randomNumberBound);
//    }
//
//    @Override
//    public DoubleStream doubles(double randomNumberOrigin, double randomNumberBound) {
//        return super.doubles(randomNumberOrigin, randomNumberBound);
//    }

//    @Override
//    public int hashCode() {
//        return mtf.hashCode();
//    }
//
//    @Override
//    public boolean equals(Object obj) {
//        return mtf.equals(obj);
//    }
//
//    @Override
//    protected Object clone() throws CloneNotSupportedException {
//        return mtf.clone();
//    }
//
//    @Override
//    public String toString() {
//        return mtf.toString();
//    }


}


