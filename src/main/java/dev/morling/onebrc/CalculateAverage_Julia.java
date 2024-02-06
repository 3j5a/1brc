/*
 *  Copyright 2023 The original authors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package dev.morling.onebrc;

import java.io.IOException;

import static java.lang.ProcessBuilder.Redirect.*;

public class CalculateAverage_Julia {

    private static final String FILE = "./measurements.txt";

    public static void main(String[] args) throws IOException, InterruptedException {
        if (args.length == 0) {
            System.out.println("fork must be specified");
            System.exit(0);
        }
        var fork = args[0];
        var julia = new ProcessBuilder("julia", "src/main/julia/CalculateAverage_" + fork + ".jl", FILE);
        var environment = julia.environment();
        for (int i = 1; i < args.length - 1; i++) {
            environment.put(args[i], args[i + 1]);
        }
        julia.redirectOutput(INHERIT).redirectError(INHERIT).start().waitFor();
    }

}
