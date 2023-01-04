function value= getValueDictionary(dictionary,var_name)
data_dict = Simulink.data.dictionary.open(dictionary);
dDataSectObj = getSection(data_dict,'Design Data');
entry = getEntry(dDataSectObj,var_name);
value = getValue(entry);
value = value.Value;
end

