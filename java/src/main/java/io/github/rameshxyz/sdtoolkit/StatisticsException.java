package io.github.rameshxyz.sdtoolkit;

/** Thrown for empty, too-short or invalid input, or a zero mean in relative statistics. */
public class StatisticsException extends IllegalArgumentException {
    private static final long serialVersionUID = 1L;

    public StatisticsException(String message) {
        super(message);
    }
}
