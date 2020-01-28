package test;

import test.*;

class Runner extends haxe.unit.TestRunner {
    public static function main() {
        var runner = new Runner();     
        runner.add( new TestStringExt() );
        runner.add( new TestModal() );
        runner.run();
    }
}
