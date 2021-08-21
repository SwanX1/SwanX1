## Java Build
A short(ish) bash script that compiles java projects without the need of complex frameworks like Gradle, Maven, and Ant.

#### How to use:

Write all your code in `src` (can contain subdirectories), put links to dependency jars in `dependencies.txt`, and run the script!

Full help info:
                                                                                        
    usage: ./build.sh [OPTIONS]                                                             
                                                                                            
    Options:                                                                                
                                                                                            
      -h, --help                            Display this screen and exit                    
      -v, --version                         Display version information and exit            
                                                                                            
    Logging options:                                                                        
      -q, --quiet                           Shut up. (Do not log anything)                  
      -d, --debug, --verbose                Log more then usual.                            
                                                                                            
    Build options:                                                                          
      -m, --main, --main-class              Specify main class                              
      -o, --out, --outfile, --jar [FILE]    JAR file (default: ./build/output.jar)          
                                                                                            
    Dependency options:                                                                     
      --download-dependencies               Don't build, only download dependencies and exit
                                                                                            
      --dependencies, --dependencies-file   Dependency listing (default: ./dependencies.txt)
        [FILE]                                                                              
                                                                                            
      --include-dependencies                Include dependency classes in JAR (default)     
      --exclude-dependencies                Do not include dependency classes in JAR        
                                                                                            
    Download options:                                                                       
      --download                            Download dependencies (default)                 
      --no-download                         Avoid downloading anything                      
                                                                                            