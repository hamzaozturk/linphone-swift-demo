# linphone-swift-demo

[linphone](https://www.linphone.org/) is an open source VOIP project. In this repository, we demonstrate how to integrate [liblinphone](http://www.linphone.org/technical-corner/liblinphone/overview) library into a swift project. We include 3 common scenarios:

- make a phone call
- auto accept an incoming call
- registration and idle 

## Usage

1. Remember to modify Secret.plist to your account

2. Modify `demo()` in `LinphoneManager.swift` to test different scenario. 
        
3. Run the app, look your console to get the linphone output details.

## Example 

Make a sip call:

    let calleeAccount = "SIP_NUMBER" // ex: 32423423423
    ...
    func demo() {
        makeCall()
    }   
         
## License

The MIT License

Copyright (c) 2019

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
