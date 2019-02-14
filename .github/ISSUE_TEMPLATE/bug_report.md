---
name: Bug report
about: Guidelines to submit a detailed new bug report issue
title: ''
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Configure '...'
2. Build '...'
3. Experience error '...'

**Provide error log**
1. Start with a new build directory 
2. Configure your build with CMake and note your configuration settings (you will need to report these)
3. Run `make -j4 -k` ... you can change the 4 to something reflective of how may cores you want to use. The -k is critical as well. 
4. Once the build fails run `make &> log_failure.txt` and provide that log.

**Machine details (please complete the following information):**
- OS: [e.g. Ubuntu 16.04)
- CMake version
- Compiler and version [e.g. GCC 4.8.1]
- Fletch version or branch with commit hash
- Exact Fletch CMake options

**Additional context**
Add any other context about the problem can go here.
