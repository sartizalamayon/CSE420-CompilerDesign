#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;

    // Write necessary attributes to store what type of symbol it is (Variable/Array/Function)
    string ID_type;

    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...)
    string data_type;

    // Write necessary attributes to store the parameters of a function
    int no_of_parameters;
    vector<string> param_type;
    vector<string> param_name;
     

    // Write necessary attributes to store the array size if the symbol is an array
    int array_size;
public:
    symbol_info(string name, string type) {
        this->name = name;
        this->type = type;
        no_of_parameters = 0;
        array_size = -1;      
    }
    string get_name()
    {
        return name;
    }
    string get_type()
    {
        return type;
    }
    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }
    // Write necessary functions to set and get the attributes
    // Getter and Setter for ID_type
    string get_ID_type() {
        return ID_type;
    }

    void set_ID_type(string ID_type) {
        this->ID_type = ID_type;
    }


    // Getter and Setter for data_type (return type or variable type)
    string get_data_type() {
        return data_type;
    }

    void set_data_type(string data_type) {
        this->data_type = data_type;
    }

   
    // Getter and Setter for number of parameters (for functions)
    int get_no_of_parameters() {
        return no_of_parameters;
    }

    void set_no_of_parameters(int no_of_parameters) {
        this->no_of_parameters = no_of_parameters;
    }


    vector<string> get_param_name() {
        return param_name;
    }

    void set_param_name(vector<string> param_name) {
        this->param_name = param_name;
    }


    // Getter and Setter for param_type (for functions)
    vector<string> get_param_type() {
        return param_type;
    }

    void set_param_type(vector<string> param_type) {
        this->param_type = param_type;
    }


    // Getter and Setter for array size (for arrays)
    int get_array_size() {
        return array_size;
    }

    void set_array_size(int array_size) {
        this->array_size = array_size;
    }




    ~symbol_info()
    {
        // Write necessary code for the deconstructor
        this->param_name.clear();
        this->param_type.clear();
    }
};