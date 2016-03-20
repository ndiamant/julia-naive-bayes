############################################
#=
Nathaniel Diamant 
ndiamant@hmc.edu 

Naive Bayes Classifier with multinomial text representation

Enter a directory of class A text files, a directory of class B text files,
and a directory of text files you want classified and get a dictionary 
of classified files
=#
############################################

function classifyFiles(dirA, dirB, dirInput)

    numberClassA = size(readdir(dirA))[1]
    numberClassB = size(readdir(dirB))[1]


    # takes a directory of all text files and returns 
    # a frequency dictionary of those words
    function dirToFreqDict(fileName)
        
        textFileList = readdir(fileName)
        cd(fileName)
        textFileList = map(open, textFileList)
        textList = map(readall, textFileList)
        map(close, textFileList)
        

        function textToWords(string)
            return split(string)
        end

        textList = map(textToWords, textList)

        freqDict = Dict()
        function makeFreqDict(wordList)   
            #makes and returns frequency dictionary from an array of words
                      
            function addToFreqDict(word)
                if haskey(freqDict, word)
                    freqDict[word] = freqDict[word] + 1
                else
                    freqDict[word] = 1
                end
            end

            map(addToFreqDict, wordList)

        end
        
        cd("..")    
        map(makeFreqDict, textList)
        return freqDict
    end


    function makeLogProbDict(freqDict)
    # makes a dictionary into a log probability dictionary
        logTotalWords = log(sum(values(freqDict)))
        newDict = Dict()
        for key in keys(freqDict)
            newDict[key] = log(freqDict[key]) - logTotalWords
        end
        return newDict
    end

    classAfreqDict = makeLogProbDict(dirToFreqDict(dirA))
    classBfreqDict = makeLogProbDict(dirToFreqDict(dirB))

    function dirToFreqDictArray(dir)
        textFileList = readdir(dir)
        cd(dir)
        
        function fileToTuple(fileName)
            file = open(fileName)
            result = fileName, readall(file)
            close(file)
            return result
        end
        
        textList = map(fileToTuple, textFileList) 

        function textToWords(fileStringTuple)
            return fileStringTuple[1], split(fileStringTuple[2])
        end

        textList = map(textToWords, textList)


        function makeFreqDict(wordListTuple)   
            #makes and returns frequency dictionary from an array of words         
            freqDict = Dict()
            function addToFreqDict(word)
                if haskey(freqDict, word)
                    freqDict[word] = freqDict[word] + 1
                else
                    freqDict[word] = 1
                end
            end

            map(addToFreqDict, wordListTuple[2])

            return wordListTuple[1], freqDict
        end

        cd("..")
        return map(makeFreqDict, textList)
        
    end

    inputFreqDictArray = dirToFreqDictArray(dirInput)


    function classifyFreqDict(freqDictTuple)
        # TODO: investigate default values based on probabilistic model
        defaultClassAValue = log(1/1000/(numberClassA+numberClassB))
        defaultClassBValue = defaultClassAValue
    
        classATotal = log(numberClassA / (numberClassA + numberClassB))

        for key in keys(freqDictTuple[2])
            classATotal += freqDictTuple[2][key] * get(classAfreqDict, key, defaultClassAValue)
        end

        classBTotal = log(numberClassB / (numberClassA + numberClassB))

        for key in keys(freqDictTuple[2])
            classBTotal += freqDictTuple[2][key] * get(classBfreqDict, key, defaultClassBValue)
        end

        if classATotal > classBTotal
            return freqDictTuple[1], 1
        end

       return freqDictTuple[1], 0

    end

    return map(classifyFreqDict, inputFreqDictArray)

end