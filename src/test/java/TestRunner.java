package regresion;

import com.intuit.karate.junit5.Karate;

class TestRunner {
    @Karate.Test
    Karate testRegresion() {
        return Karate.run("classpath:regresion/regresion.feature").relativeTo(getClass());
    }
}