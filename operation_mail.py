import imaplib
import email


# noinspection PyMethodMayBeStatic
class OperationMail:

    def download_attach(self):

        main_server = imaplib.IMAP4_SSL('imap.gmail.com')
        main_server.login('boris890221@gmail.com', 'boris1234')

        main_server.select('inbox')

        result, company_mail_list = main_server.search(None, 'FROM', 'report@tsrs.co.jp')

        if result == 'OK':
            mail_ids = company_mail_list[0]

            last_id_list = mail_ids.split()[-1]

            result, mail_data_response = main_server.fetch(last_id_list, '(RFC822)')

            mail_obj = mail_data_response[0][1]

            mail_body = email.message_from_bytes(mail_obj)
            
            # msg_encoding = email.header.decode_header(mail_body.get('Subject'))[0][1] or 'iso-2022-jp'
            # main_body_after_encode = email.message_from_string(mail_obj.decode(msg_encoding))
            # title = ""
            # for sub in email.header.decode_header(main_body_after_encode.get('Subject')):
            #     if isinstance(sub[0], bytes):
            #         title += sub[0].decode(msg_encoding)
            #     else:
            #         title += sub[0]
            # print(title)

            for mail_part in mail_body.walk():

                if mail_part.get_content_maintype() == 'multipart':
                    continue

                if mail_part.get('Content-Disposition') is None:
                    continue

                # all thing from gmail is based on Basea64, need to encoding and decode

                file_name = ''
                for name_str in email.header.decode_header(mail_part.get_filename()):
                    if isinstance(name_str[0], bytes):
                        file_name += name_str[0].decode('iso-2022-jp')
                    else:
                        file_name += name_str[0]

                with open('/Users/boris/' + file_name, 'wb') as file:
                    file.write(mail_part.get_payload(decode=True))


if __name__ == '__main__':

    operationMail = OperationMail()
    operationMail.download_attach()
