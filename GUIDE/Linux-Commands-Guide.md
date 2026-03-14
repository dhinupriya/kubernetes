# Linux & Shell Commands Guide

## Table of Contents
- [Understanding Command Structure](#understanding-command-structure)
- [Basic Commands](#basic-commands)
- [File and Directory Operations](#file-and-directory-operations)
- [Special Characters & Symbols](#special-characters--symbols)
- [Docker Commands](#docker-commands)
- [Kubernetes (kubectl) Commands](#kubernetes-kubectl-commands)
- [Advanced Concepts](#advanced-concepts)
- [Common Patterns in POC](#common-patterns-in-poc)

---

## Understanding Command Structure

### Basic Pattern
```
command [options] [arguments]
```

### Examples
```bash
ls                    # command only
ls -la               # command + options
ls -la /home         # command + options + argument
docker build -t app:1.0 .  # command + option with value + argument
```

---

## Basic Commands

### Navigation

#### `pwd` - Print Working Directory
**What it does:** Shows your current location

```bash
pwd
# Output: /Users/dhinupriya/Documents/Kubernetes
```

**Think of it as:** "Where am I?"

---

#### `cd` - Change Directory
**What it does:** Move to a different folder

```bash
cd demo              # Go into 'demo' folder
cd ..               # Go up one level (parent folder)
cd ~                # Go to home directory
cd /Users/name      # Go to specific path
```

**Examples:**
```bash
# You are here: /Users/dhinupriya/Documents
cd Kubernetes
# Now here: /Users/dhinupriya/Documents/Kubernetes

cd ..
# Now here: /Users/dhinupriya/Documents
```

---

#### `ls` - List
**What it does:** Shows files and folders

```bash
ls                  # List files in current directory
ls -l              # List with details (long format)
ls -a              # List all (including hidden files)
ls -la             # List all with details
ls /path/to/folder # List files in specific folder
```

**Output example:**
```bash
ls -la
# drwxr-xr-x   5 user  staff   160 Jan 29 10:30 demo
# -rw-r--r--   1 user  staff  1234 Jan 29 10:25 pom.xml
# -rw-r--r--   1 user  staff   456 Jan 29 10:20 Dockerfile
```

---

### File Operations

#### `cat` - Concatenate (View file contents)
**What it does:** Display entire file contents

```bash
cat filename.txt
cat pom.xml
```

---

#### `mkdir` - Make Directory
**What it does:** Create a new folder

```bash
mkdir my-folder
mkdir -p parent/child/grandchild  # Create nested folders
```

---

#### `touch` - Create Empty File
**What it does:** Create a new empty file

```bash
touch newfile.txt
touch Dockerfile
```

---

#### `cp` - Copy
**What it does:** Copy files or folders

```bash
cp file.txt copy.txt           # Copy file
cp -r folder1 folder2          # Copy folder recursively
```

---

#### `mv` - Move (also rename)
**What it does:** Move or rename files/folders

```bash
mv oldname.txt newname.txt     # Rename
mv file.txt /other/folder/     # Move to different location
```

---

#### `rm` - Remove
**What it does:** Delete files or folders

```bash
rm file.txt                    # Delete file
rm -r folder                   # Delete folder and contents
rm -rf folder                  # Force delete (be careful!)
```

⚠️ **Warning:** `rm` is permanent - no trash/recycle bin!

---

## Special Characters & Symbols

### The Dot (`.`)

#### Single Dot `.` - Current Directory
**What it means:** "Right here" or "this folder"

```bash
docker build -t my-app:1.0 .
#                           ↑
#                    "Build using files in current folder"

ls .                  # List current directory (same as just 'ls')
```

#### Double Dot `..` - Parent Directory
**What it means:** "One level up" or "parent folder"

```bash
cd ..                 # Go up one level

# If you're in: /Users/dhinupriya/Documents/Kubernetes
# After cd ..: /Users/dhinupriya/Documents
```

---

### The Slash (`/`)

#### Root Directory
```bash
/                     # The very top of the file system
/Users                # Absolute path from root
```

#### Path Separator
```bash
/Users/dhinupriya/Documents
  ↑     ↑           ↑
  Separates folder names
```

---

### The Tilde (`~`)

**What it means:** Your home directory

```bash
cd ~                  # Go to home directory
# Same as: cd /Users/dhinupriya

ls ~/Documents        # List files in your Documents folder
# Same as: ls /Users/dhinupriya/Documents
```

---

### The Asterisk (`*`)

**What it means:** Wildcard - matches anything

```bash
*.jar                 # All files ending with .jar
*.txt                 # All .txt files
test*                 # Files starting with 'test'

# In Dockerfile:
COPY target/*.jar app.jar
#           ↑
#    "Copy any .jar file from target folder"
```

---

### The Dollar Sign (`$`)

#### 1. Environment Variables
```bash
echo $HOME            # Print HOME variable value
echo $PATH            # Print PATH variable

# In commands:
$(minikube docker-env)
# ↑
# "Run this command and use its output"
```

#### 2. Command Substitution `$(...)`
```bash
eval $(minikube docker-env)
#    ↑─────────────────────┘
#    Run this command first, then use its output

# Example breakdown:
minikube docker-env
# Outputs: export DOCKER_HOST="tcp://..."

eval $(minikube docker-env)
# Becomes: eval export DOCKER_HOST="tcp://..."
# Which actually runs: export DOCKER_HOST="tcp://..."
```

---

### The Pipe (`|`)

**What it means:** Send output of one command to another

```bash
docker images | grep my-app
#             ↑
#    Take output from left, send to right

# Breakdown:
# docker images        → Lists all images
# grep my-app          → Filters to show only lines with "my-app"
```

**More examples:**
```bash
ls -l | grep .jar           # List files, show only .jar files
kubectl get pods | grep Running  # Show only running pods
cat file.txt | wc -l        # Count lines in file
```

---

### Double Ampersand (`&&`)

**What it means:** Run second command only if first succeeds

```bash
cd demo && ls
# ↑          ↑
# First    Then this (only if cd succeeds)

mvn clean package && docker build -t app:1.0 .
# Build Java → if success → Build Docker image
```

**vs Single `&`** (run in background - different!)

---

### Semicolon (`;`)

**What it means:** Run commands in sequence (regardless of success)

```bash
cd demo ; ls
# Run cd, then run ls (even if cd fails)
```

---

### Greater Than (`>` and `>>`)

#### `>` - Redirect output (overwrite)
```bash
echo "Hello" > file.txt     # Write to file (overwrites)
ls > files.txt              # Save list to file
```

#### `>>` - Redirect output (append)
```bash
echo "World" >> file.txt    # Append to file
```

---

### Dash and Double Dash (`-` and `--`)

#### Single Dash `-` - Short options
```bash
ls -l                 # Long format
ls -a                 # All files
ls -la                # Combined: -l and -a
docker build -t       # Tag option
```

#### Double Dash `--` - Long options
```bash
docker build --tag my-app:1.0
kubectl get pods --all-namespaces
minikube start --driver=docker
```

**They often mean the same:**
```bash
docker build -t my-app:1.0
docker build --tag my-app:1.0
# Both do the same thing!
```

---

## Paths: Relative vs Absolute

### Absolute Path
**Starts from root (`/`)**

```bash
/Users/dhinupriya/Documents/Kubernetes
# Always refers to the same location, no matter where you are
```

### Relative Path
**Starts from current directory**

```bash
# If you're in: /Users/dhinupriya/Documents

Kubernetes/pom.xml         # Relative to current location
./Kubernetes/pom.xml       # Same thing (. = current directory)
../Downloads/file.txt      # Up one level, then into Downloads
```

### Examples:
```bash
# You are in: /Users/dhinupriya/Documents/Kubernetes

cd demo                    # Relative: go to demo inside current folder
cd ./demo                  # Same thing
cd /Users/dhinupriya/demo  # Absolute: go to exact location

# In Docker build:
docker build -t app:1.0 .
#                       ↑
# Current directory (relative)
```

---

## Docker Commands

### `docker build`
**What it does:** Create a Docker image from a Dockerfile

```bash
docker build -t my-java-app:1.0 .
```

**Breaking it down:**
- `docker` = The command
- `build` = Subcommand (what action)
- `-t` = Tag option (name the image)
- `my-java-app:1.0` = Image name:version
- `.` = Build context (use files in current directory)

**What happens:**
1. Reads `Dockerfile` in current directory
2. Follows instructions in Dockerfile
3. Creates an image named `my-java-app` with tag `1.0`

---

### `docker images`
**What it does:** List all Docker images

```bash
docker images

# Output:
REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
my-java-app     1.0       abc123def456   2 minutes ago   350MB
```

**With filter:**
```bash
docker images | grep my-java-app
# Show only lines containing "my-java-app"
```

---

### `docker run`
**What it does:** Run a container from an image

```bash
docker run -p 8080:8080 my-java-app:1.0
```

**Breaking it down:**
- `docker run` = Start a container
- `-p 8080:8080` = Port mapping (host:container)
- `my-java-app:1.0` = Which image to run

---

### `docker ps`
**What it does:** List running containers

```bash
docker ps                  # Show running containers
docker ps -a              # Show all containers (including stopped)
```

---

### `eval $(minikube docker-env)`
**What it does:** Point Docker commands to Minikube's Docker

```bash
eval $(minikube docker-env)
```

**Step by step:**
1. `minikube docker-env` outputs environment variables
2. `$(...)` runs the command and captures output
3. `eval` executes the captured output as shell commands
4. Result: Docker CLI now talks to Minikube's Docker daemon

---

## Kubernetes (kubectl) Commands

### `kubectl apply`
**What it does:** Create or update resources from a file

```bash
kubectl apply -f deployment.yaml
```

**Breaking it down:**
- `kubectl` = Kubernetes CLI
- `apply` = Create/update resources
- `-f` = From file
- `deployment.yaml` = The configuration file

---

### `kubectl get`
**What it does:** Display resources

```bash
kubectl get pods                    # List all pods
kubectl get services                # List all services
kubectl get deployments             # List all deployments
kubectl get pods -o wide            # More details
kubectl get pods --all-namespaces   # From all namespaces
```

---

### `kubectl describe`
**What it does:** Show detailed information about a resource

```bash
kubectl describe pod my-pod-name
kubectl describe deployment my-app
```

**Use when:** Debugging, seeing events, understanding why something isn't working

---

### `kubectl logs`
**What it does:** View container logs

```bash
kubectl logs my-pod-name           # View logs
kubectl logs -f my-pod-name        # Follow logs (live)
kubectl logs --tail=50 my-pod-name # Last 50 lines
```

---

### `kubectl exec`
**What it does:** Execute command inside a pod

```bash
kubectl exec -it my-pod-name -- /bin/sh
```

**Breaking it down:**
- `exec` = Execute command
- `-it` = Interactive terminal
- `my-pod-name` = Which pod
- `--` = Separator (everything after goes to container)
- `/bin/sh` = Command to run (open shell)

---

### `kubectl scale`
**What it does:** Change number of replicas

```bash
kubectl scale deployment my-app --replicas=5
```

---

### `kubectl port-forward`
**What it does:** Forward local port to pod/service

```bash
kubectl port-forward service/my-service 8080:8080
```

**Breaking it down:**
- Local port 8080 (your laptop)
- → Pod/Service port 8080
- Access at: `http://localhost:8080`

---

## curl Command

### `curl` - Transfer data from/to a server
**What it does:** Make HTTP requests (like a browser, but in terminal)

```bash
curl http://localhost:8080/api/Hello/World
```

**Breaking it down:**
- `curl` = The command
- `http://localhost:8080` = Server address
- `/api/Hello/World` = The endpoint path

**For your Spring Boot example:**
```java
@RequestMapping("/api/Hello")  // Base path
public class Controller {
    @GetMapping("/World")      // Endpoint path
    // ...
}
```

**Full URL:** `http://localhost:8080/api/Hello/World`

**curl command:**
```bash
curl http://localhost:8080/api/Hello/World
# Output: Hello! Welcome to Kubernetes Demo
```

**Common options:**
```bash
curl http://example.com                    # Simple GET request
curl -X POST http://example.com            # POST request
curl -H "Content-Type: application/json"   # Add header
curl -d '{"key":"value"}'                  # Send data
```

---

## Maven Commands

### `mvn clean package`
**What it does:** Build your Java project

```bash
mvn clean package
```

**Breaking it down:**
- `mvn` = Maven command
- `clean` = Delete old compiled files
- `package` = Compile and create JAR file

**Result:** Creates JAR in `target/` folder
- Example: `target/demo-0.0.1-SNAPSHOT.jar`

---

### Finding Your JAR Name

```bash
# After running mvn clean package:
ls target/*.jar

# Output shows your JAR name:
# target/demo-0.0.1-SNAPSHOT.jar
```

**JAR name comes from `pom.xml`:**
```xml
<artifactId>demo</artifactId>
<version>0.0.1-SNAPSHOT</version>
```
= `demo-0.0.1-SNAPSHOT.jar`

---

## Common Patterns in POC

### Pattern 1: Build Java, then Docker

```bash
# Step 1: Build Java application
mvn clean package

# Step 2: Build Docker image
docker build -t my-java-app:1.0 .
```

**What happens:**
1. Maven creates JAR in `target/` folder
2. Docker reads Dockerfile
3. Dockerfile copies JAR from `target/` folder
4. Docker creates image

---

### Pattern 2: Check if something exists

```bash
docker images | grep my-java-app
kubectl get pods | grep Running
```

**Pattern:**
```bash
[list command] | grep [search term]
```

---

### Pattern 3: Chained commands

```bash
cd demo && mvn clean package && docker build -t app:1.0 .
```

**Reads as:**
1. Change to demo directory
2. If successful → Build Java project
3. If successful → Build Docker image

If any step fails, chain stops!

---

### Pattern 4: View live output

```bash
kubectl logs -f my-pod-name
kubectl get pods -w
```

**The `-f` or `-w` flags:**
- `-f` = Follow (keep showing new logs)
- `-w` = Watch (keep updating)
- Press `Ctrl+C` to stop

---

## Quick Reference Table

| Symbol | Meaning | Example |
|--------|---------|---------|
| `.` | Current directory | `docker build -t app .` |
| `..` | Parent directory | `cd ..` |
| `~` | Home directory | `cd ~` |
| `/` | Root or separator | `/Users/name` |
| `*` | Wildcard (any) | `*.jar` |
| `$` | Variable or substitution | `$HOME`, `$(command)` |
| `\|` | Pipe output | `ls \| grep txt` |
| `&&` | And (run if success) | `cd demo && ls` |
| `;` | Sequential | `cd demo ; ls` |
| `>` | Redirect (overwrite) | `ls > file.txt` |
| `>>` | Redirect (append) | `ls >> file.txt` |
| `-` | Short option | `-t`, `-f` |
| `--` | Long option | `--tag`, `--file` |

---

## Tips for Learning

### 1. Use `--help` or `man`
```bash
docker build --help
kubectl get --help
man ls
```

### 2. Start Simple
```bash
# Don't start with:
docker build -t my-app:1.0 -f Dockerfile.prod --build-arg VERSION=1.0 .

# Start with:
docker build -t my-app .
# Then add options as you learn
```

### 3. Break Down Complex Commands
```bash
# This complex command:
eval $(minikube docker-env)

# Break it down:
minikube docker-env        # Step 1: What does this output?
$(minikube docker-env)     # Step 2: Capture that output
eval $(minikube docker-env) # Step 3: Execute the output
```

### 4. Use Tab Completion
- Type part of command/filename
- Press Tab
- Shell completes it for you!

```bash
cd Doc[TAB]       # Completes to: cd Documents/
kubectl get po[TAB]  # Completes to: kubectl get pods
```

---

## Common Mistakes

### 1. Forgetting the dot (`.`)
```bash
docker build -t my-app:1.0     # ❌ Error: needs build context
docker build -t my-app:1.0 .   # ✅ Correct
```

### 2. Wrong directory
```bash
# You're in: /Users/dhinupriya
docker build -t app .          # ❌ No Dockerfile here

cd Documents/Kubernetes/demo   # Go to right place
docker build -t app .          # ✅ Now it works
```

### 3. Mixing up paths
```bash
cd demo         # Relative path (looks in current directory)
cd /demo        # Absolute path (looks at root / )
```

### 4. Forgetting quotes for spaces
```bash
cd My Documents        # ❌ Error
cd "My Documents"      # ✅ Correct
cd My\ Documents       # ✅ Also correct (escape space)
```

---

## Practice Exercises

### Exercise 1: Navigation
```bash
# Starting at home directory
pwd                    # Where am I?
cd Documents          # Go to Documents
pwd                   # Verify
cd ..                 # Go back up
pwd                   # Check again
```

### Exercise 2: Working with Files
```bash
mkdir test-folder     # Create folder
cd test-folder       # Go into it
touch test.txt       # Create file
ls                   # List files
cd ..               # Go back
rm -r test-folder   # Clean up
```

### Exercise 3: Docker Flow
```bash
# In your Java project directory
ls                           # Check files exist
mvn clean package           # Build Java
ls target/*.jar             # Find your JAR
docker build -t test-app .  # Build image
docker images | grep test   # Verify image exists
```

---

## Troubleshooting Commands

### When lost:
```bash
pwd                    # Where am I?
ls                    # What's here?
cd ~                  # Go home
```

### When Docker issues:
```bash
docker ps             # What's running?
docker images         # What images exist?
docker --version      # Is Docker installed?
```

### When Kubernetes issues:
```bash
kubectl get pods              # Are pods running?
kubectl get nodes            # Is cluster ready?
kubectl describe pod [name]  # Why is pod failing?
kubectl logs [pod-name]      # What are the logs?
```

---

## Summary

**You now understand:**
- ✅ Command structure
- ✅ Special characters (`.`, `*`, `$`, `|`, etc.)
- ✅ Paths (relative vs absolute)
- ✅ Docker commands
- ✅ kubectl commands
- ✅ Common patterns

**Remember:**
- Start simple, build up complexity
- Use `--help` when stuck
- Break down complex commands into parts
- Practice with safe commands first

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Companion to:** Kubernetes-Java-POC-Guide.md
