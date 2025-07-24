function Write-ReverseOuput {
    [Alias('Write-Output')]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $InputObject
    )

    end {
        #Turn our string input into an array of chars
        $charArray = $InputObject.ToCharArray()
        
        #the reverse method on the [Array] class reverse the characters in place. 
        #No need to store them in another variable, and it has no output to squash!
        [Array]::Reverse($charArray)

        #We then join our reversed char array back into its original string representation, and output it...this time only backwards :)
        -join($charArray)
    }
}