pragma solidity >=0.4.22 <0.6.0;

contract Factoriel {
    function iterativeFact(uint32 a)
    public
    pure
    returns (uint64){
        uint32 result=a;
        
        for(uint32 i = a-1; i>0; i--){
            result *= i;
        }
        
        return result;
    }

    //result should start form 1
    function recursiveFact(uint64 result, uint32 a)
    public
    pure
    returns (uint64){
        if(a==1){
            return result;
        }else{
            return recursiveFact(result*a, a-1);
        }
    }
}