@RestResource(urlMapping='/serialized')
global with sharing class DeleteSerializedApi {
    
    @HttpDelete
    global static void deleteRecords(){
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try{
            String ids = RestContext.request.params.get('ids');

            List<String> listIds = new List<String>();
            listIds = ids.split(',');
            System.debug('listIds -> '+ listIds);

            List<Database.DeleteResult> result = new List<Database.DeleteResult>();

            result = DeleteSerializedController.deleteAllRecords(listIds);

            ResWrapper resp = new ResWrapper();
            resp.erros = new List<Erros>();
            for (Database.DeleteResult sr : result) {
                if (!sr.isSuccess()) {
                    System.debug('Erro ao deletar o registro X');
                    Erros er = new Erros();
                    er.serial = sr.getId();
                    for(Database.Error e : sr.getErrors()){
                        System.debug('e -> '+ e);
                        er.mensagemSerial = tratarMensagem(e.getmessage());
                        break;
                    }
                    resp.erros.add(er);
                }
            }
            if(resp.erros.size()>0){
                res.statusCode=400;
                resp.mensagem = 'Erro ao deletar registros.';
                res.responseBody=Blob.valueOf(Json.serialize(resp));
            }else{
                res.statusCode=201;
                resp.mensagem = 'Registros deletados.';
                res.responseBody=Blob.valueOf(Json.serialize(resp));
            }
        }catch(Exception ex){
            res.statusCode=400;
            res.responseBody=Blob.valueOf(ex.getMessage());
        }
    }
    public class ResWrapper{
        public String mensagem {get;set;}
        public List<Erros> erros {get;set;}
    }
    public class Erros{
        public String serial {get; set;}
        public String mensagemSerial {get; set;}
    }
    public static String tratarMensagem(String mensagem){

        switch on mensagem{
            when 'entity is deleted'{
                return 'Registros já deletados';
            }
            when else{
                if(mensagem.contains('malformed id')){
                    return 'Dado inválido';
                }
            }
        }
        return mensagem;
    }

}