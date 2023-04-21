import java.io.File;
import java.io.FileNotFoundException;
import java.util.Optional;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;
import com.github.javaparser.ast.body.*;
import com.github.javaparser.Range;
import com.github.javaparser.Position;
import com.github.javaparser.ast.expr.SimpleName;

// prints method name that contains specified line number
// code adapted from 
// https://stackoverflow.com/questions/7360311/how-to-get-surrounding-method-
// in-java-source-file-for-a-given-line-number
public class ParseTestMethod {
  static Position pos;

  public static void printMethod(File src) throws FileNotFoundException {
    CompilationUnit cu = StaticJavaParser.parse(src); 
    new MethodLineNumberVisitor().visit(cu, null);
  }

  public static void main(String[] args){
    if (args.length == 0){
      System.out.println("Test file path command line argument is required.");
      System.exit(1);
    }

    if (args.length == 1){
      System.out.println("Line number command line argument is required.");
      System.exit(1);
    }


    int lineNumber = Integer.parseInt(args[1]);
    pos = new Position(lineNumber, 0);

    File src = new File(args[0]);
    
    try {
      printMethod(src);
    } catch (Exception e){
      e.printStackTrace();
    }
  }

  private static class MethodLineNumberVisitor extends VoidVisitorAdapter {
    @Override
        public void visit(MethodDeclaration md, Object arg){
          Range r = md.getRange().get();
          
          if (r.strictlyContains(pos)){
            System.out.println(md.getName().getIdentifier());
          }
        }
  }
}